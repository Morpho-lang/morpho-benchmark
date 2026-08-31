#!/usr/bin/env python3
# Common automated benchmarking
# T J Atherton Mar 2021, updated 2026

"""Run morpho-benchmark suites from a target folder.

Interpreters are taken from PATH; a language is only timed when both its
command and a matching source file are present. If a benchmark directory
contains in.txt, the first line is passed as a program argument.
"""

from __future__ import annotations

import argparse
import os
import shutil
import statistics
import struct
import subprocess
import sys
import time
from pathlib import Path

SAMPLES = 5
CV_LIMIT = 0.01
SWEEP_SENTINEL = "sweep"

# Commands to look for, in preference order. Versioned Python binaries are
# listed separately so multiple installed CPython versions can be compared.
_PYTHON_EXTS = (".py",)
CANDIDATES = (
    [("morpho6", (".morpho",)), ("morpho", (".morpho",))]
    + [(f"python3.{v}", _PYTHON_EXTS) for v in range(20, 8, -1)]
    + [
        ("python3", _PYTHON_EXTS),
        ("lua", (".lua",)),
        ("ruby", (".ruby", ".rb")),
        ("perl", (".perl", ".pl")),
        ("wren", (".wren",)),
        ("wren_cli", (".wren",)),
        ("wren-cli", (".wren",)),
    ]
)

# Homebrew and some builds install Wren as wren_cli / wren-cli.
DISPLAY_NAMES = {
    "wren_cli": "wren",
    "wren-cli": "wren",
}

SKIP_DIRS = {"tools", "__pycache__"}
SKIP_FILES = {"benchmark.py"}

# -O compiles with the optimizer; --eval imports bytecodeoptimizer first so
# morpho_setoptimizer is registered before the file is compiled.
# Keep -wN as one token (attached form is unambiguous).
MORPHO_OPTIMIZE_ARGS = ("--eval", "import bytecodeoptimizer", "-O")


def green(text):
    if sys.stdout.isatty():
        return f"\033[32m{text}\033[0m"
    return text


def grey(text):
    if sys.stdout.isatty():
        return f"\033[90m{text}\033[0m"
    return text


def is_morpho(name):
    return name.startswith("morpho")


def _read_int(path):
    try:
        return int(Path(path).read_text().strip())
    except (OSError, ValueError):
        return None


def _darwin_pcores():
    for key in ("hw.perflevel0.physicalcpu", "hw.physicalcpu"):
        try:
            n = int(
                subprocess.check_output(
                    ["sysctl", "-n", key],
                    text=True,
                    stderr=subprocess.DEVNULL,
                ).strip()
            )
        except (OSError, ValueError, subprocess.CalledProcessError):
            continue
        if n > 0:
            return n, f"darwin {key}"
    return None, None


def _linux_pcores():
    """Unique physical cores in the highest-frequency (or capacity) class."""
    cpu_root = Path("/sys/devices/system/cpu")
    if not cpu_root.is_dir():
        return None, None
    groups = {}
    used_freq = False
    for cpu in cpu_root.iterdir():
        if not cpu.name.startswith("cpu") or not cpu.name[3:].isdigit():
            continue
        key = _read_int(cpu / "cpufreq" / "cpuinfo_max_freq")
        if key is not None:
            used_freq = True
        else:
            key = _read_int(cpu / "cpu_capacity")
        if key is None:
            continue
        pkg = _read_int(cpu / "topology" / "physical_package_id")
        core = _read_int(cpu / "topology" / "core_id")
        ident = (pkg, core) if pkg is not None and core is not None else cpu.name
        groups.setdefault(key, set()).add(ident)
    if not groups:
        return None, None
    n = len(groups[max(groups)])
    if n <= 0:
        return None, None
    src = "linux cpuinfo_max_freq" if used_freq else "linux cpu_capacity"
    return n, src


def _windows_pcores():
    """Physical cores with EfficiencyClass 0 (P-cores on hybrid CPUs)."""
    try:
        import ctypes
        from ctypes import wintypes
    except ImportError:
        return None, None
    kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
    get_info = kernel32.GetLogicalProcessorInformationEx
    get_info.argtypes = [
        wintypes.DWORD,
        ctypes.c_void_p,
        ctypes.POINTER(wintypes.DWORD),
    ]
    get_info.restype = wintypes.BOOL
    relation_core = 0
    needed = wintypes.DWORD(0)
    if get_info(relation_core, None, ctypes.byref(needed)):
        return None, None
    if ctypes.get_last_error() != 122:  # ERROR_INSUFFICIENT_BUFFER
        return None, None
    buf = ctypes.create_string_buffer(needed.value)
    if not get_info(relation_core, buf, ctypes.byref(needed)):
        return None, None
    data = buf.raw
    offset = 0
    pcores = 0
    while offset + 10 <= needed.value:
        rel, size, _flags, efficiency = struct.unpack_from("<IIBB", data, offset)
        if size < 10:
            break
        if rel == relation_core and efficiency == 0:
            pcores += 1
        offset += size
    if pcores <= 0:
        return None, None
    return pcores, "windows EfficiencyClass"


def performance_core_guess():
    """Best-effort (P-core count, source). Falls back to os.cpu_count()."""
    if sys.platform == "darwin":
        n, src = _darwin_pcores()
        if n is not None:
            return n, src
    elif sys.platform.startswith("linux"):
        n, src = _linux_pcores()
        if n is not None:
            return n, src
    elif sys.platform == "win32":
        n, src = _windows_pcores()
        if n is not None:
            return n, src
    n = os.cpu_count()
    if n and n > 0:
        return n, "os.cpu_count"
    return None, None


def soft_worker_limit(pcores):
    """Largest -w that should stay on P-cores: P-1, or 1 on a single core."""
    if not pcores or pcores < 1:
        return None
    return max(1, pcores - 1)


def parse_workers(text):
    """Parse -w SPEC: N, sweep (1..P-1), N-M / N..M, or a comma list."""
    if text is None:
        return None
    s = text.strip().lower()
    if s == SWEEP_SENTINEL:
        return SWEEP_SENTINEL

    if "," in s:
        try:
            vals = [int(p.strip()) for p in s.split(",") if p.strip()]
        except ValueError as exc:
            raise argparse.ArgumentTypeError(
                f"invalid -w list {text!r}"
            ) from exc
        if not vals or any(n < 1 for n in vals):
            raise argparse.ArgumentTypeError("-w values must be >= 1")
        return vals

    for sep in ("..", "-"):
        if sep in s:
            left, right = s.split(sep, 1)
            if left.strip().isdigit() and right.strip().isdigit():
                a, b = int(left), int(right)
                if a < 1 or b < 1:
                    raise argparse.ArgumentTypeError("-w values must be >= 1")
                if b < a:
                    raise argparse.ArgumentTypeError(
                        f"-w range start must be <= end ({text!r})"
                    )
                return list(range(a, b + 1))

    try:
        n = int(s)
    except ValueError as exc:
        raise argparse.ArgumentTypeError(
            f"invalid -w {text!r} (use N, sweep, N-M, or N,M,…)"
        ) from exc
    if n < 1:
        raise argparse.ArgumentTypeError("-w values must be >= 1")
    return [n]


def worker_from_label(label):
    """Extract N from a -wN column label, or None."""
    for prefix in ("morpho -O -w", "morpho -w", "-w"):
        if label.startswith(prefix) and label[len(prefix) :].isdigit():
            return int(label[len(prefix) :])
    return None


def speedup_groups(columns):
    """Group sweep columns by variant: unoptimized vs morpho -O."""
    groups = []
    seen = set()
    for label in columns:
        w = worker_from_label(label)
        if w is None:
            continue
        kind = "morpho -O" if " -O " in label else ""
        if kind in seen:
            continue
        seen.add(kind)
        series = []
        for col in columns:
            cw = worker_from_label(col)
            if cw is None:
                continue
            col_kind = "morpho -O" if " -O " in col else ""
            if col_kind == kind:
                series.append((cw, col))
        series.sort()
        groups.append((kind, series))
    return groups


def expand_runtimes(runtimes, optimize, workers=None):
    """Turn detected interpreters into runnable variants.

    With -O, each morpho interpreter is included twice: once as-is and once
    with --eval "import bytecodeoptimizer" -O. --workers appends -wN (one
    token) on Morpho only; a list of worker counts expands into one column
    per count. Extra flags are -wN, then the -O preamble, then the file.
    """
    worker_list = workers if workers else [None]
    multi = workers is not None and len(workers) > 1
    expanded = []
    for name, command, extensions in runtimes:
        if not is_morpho(name):
            expanded.append((name, command, extensions, []))
            continue
        variants = [(name, [])]
        if optimize:
            variants.append(("morpho -O", list(MORPHO_OPTIMIZE_ARGS)))
        for w in worker_list:
            extra_w = [f"-w{w}"] if w is not None else []
            for base_label, opt_extra in variants:
                extra = extra_w + opt_extra
                if w is None or not multi:
                    label = base_label
                elif base_label == "morpho -O":
                    label = f"morpho -O -w{w}"
                elif len(variants) > 1:
                    label = f"morpho -w{w}"
                else:
                    label = f"-w{w}"
                expanded.append((label, command, extensions, extra))
    return expanded


def matches_filter(name, only):
    """True if name is selected. Prefixes work: python → python3.12, morpho → morpho6."""
    if only is None:
        return True
    return any(name == item or name.startswith(item) for item in only)


def resolve_morpho(spec):
    """Resolve --morpho EXE to an absolute path, or raise FileNotFoundError."""
    given = Path(spec).expanduser()
    if given.is_file():
        return str(given.resolve())
    path = shutil.which(spec)
    if path:
        return os.path.realpath(path)
    raise FileNotFoundError(f"morpho executable not found: {spec}")


def detect_runtimes(only=None, morpho=None):
    """Return [(name, command_path, extensions), ...] for commands on PATH.

    --morpho EXE replaces morpho6/morpho from PATH so a just-built binary can
    be timed without changing PATH.
    """
    seen = set()
    found = []
    skip_path_morpho = False
    if morpho is not None:
        path = resolve_morpho(morpho)
        base = Path(path).name
        label = DISPLAY_NAMES.get(base, base)
        if not is_morpho(label):
            label = "morpho"
        if matches_filter(label, only) or matches_filter(base, only):
            found.append((label, path, (".morpho",)))
            seen.add(os.path.realpath(path))
            skip_path_morpho = True

    for name, exts in CANDIDATES:
        if skip_path_morpho and name in ("morpho6", "morpho"):
            continue
        label = DISPLAY_NAMES.get(name, name)
        if not (matches_filter(name, only) or matches_filter(label, only)):
            continue
        path = shutil.which(name)
        if not path:
            continue
        real = os.path.realpath(path)
        if real in seen:
            continue
        seen.add(real)
        found.append((label, path, exts))
    return found


def known_extensions():
    exts = set()
    for _, extensions in CANDIDATES:
        exts.update(extensions)
    return exts


def is_source(path, extensions):
    return path.is_file() and path.name not in SKIP_FILES and path.suffix in extensions


def sources_in(folder, extensions):
    return [p for p in folder.iterdir() if is_source(p, extensions)]


def _path_skipped(relative_parts):
    """True if any directory on the relative path is hidden or in SKIP_DIRS."""
    return any(part.startswith(".") or part in SKIP_DIRS for part in relative_parts)


def discover(target, extensions):
    """Find benchmark directories under target.

    Recursively collects every directory that contains a source file whose
    suffix is in extensions, skipping hidden paths and SKIP_DIRS (tools,
    __pycache__).
    """
    target = Path(target).resolve()
    if not target.is_dir():
        raise FileNotFoundError(f"Not a directory: {target}")

    found = set()
    for path in target.rglob("*"):
        if not is_source(path, extensions):
            continue
        rel = path.relative_to(target)
        if _path_skipped(rel.parts[:-1]):
            continue
        found.add(path.parent)
    return sorted(found)


def pick_source(folder, extensions):
    """Choose one implementation for a language in a benchmark folder."""
    matches = sources_in(folder, extensions)
    if not matches:
        return None
    key = folder.name.lower()

    def score(path):
        name = path.name.lower()
        return (0 if name.startswith(key) else 1, name)

    return sorted(matches, key=score)[0]


def read_param(folder):
    path = folder / "in.txt"
    if not path.is_file():
        return None
    line = path.read_text().splitlines()
    if not line:
        return None
    return line[0].strip()


def sample_cv(times):
    """Sample coefficient of variation, or None if undefined."""
    if len(times) < 2:
        return None
    mean = statistics.fmean(times)
    if mean == 0:
        return 0.0
    return statistics.stdev(times) / mean


def morpho_run_failed(stderr):
    """True if morpho printed a fatal CLI error (some still exit 0)."""
    if not stderr:
        return False
    lower = stderr.lower()
    return "could not open file" in lower or "unknown option" in lower


def run(command, source, param, cwd, extra=None):
    extra = extra or []
    cmd = [command, *extra, source.name]
    if param is not None:
        cmd.append(param)

    shown = [Path(command).name, *extra, source.name]
    if param is not None:
        shown.append(param)
    print(" ".join(shown))

    start = time.perf_counter()
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            text=True,
        )
    except OSError:
        return None
    elapsed = time.perf_counter() - start
    err = result.stderr or ""
    if result.returncode != 0 or morpho_run_failed(err):
        line = err.strip().splitlines()
        if line:
            print(f"  {line[0]}", file=sys.stderr)
        return None
    return elapsed


def run_batch(label, command, source, param, folder, extra, count):
    times = []
    failures = 0
    while len(times) < count and failures < count:
        elapsed = run(command, source, param, folder, extra=extra)
        if elapsed is None:
            failures += 1
            continue
        times.append(elapsed)
    return times


def collect_times(label, command, source, param, folder, extra, batch):
    """Run `batch` samples; if cv is still >= 1%, run one more batch."""
    times = run_batch(label, command, source, param, folder, extra, batch)
    if len(times) < 2:
        return times
    cv = sample_cv(times)
    if cv is not None and cv < CV_LIMIT:
        return times
    times.extend(run_batch(label, command, source, param, folder, extra, batch))
    return times


def benchmark(folder, runtimes, batch):
    param = read_param(folder)
    print(green(folder.name))
    results = {}
    for label, command, extensions, extra in runtimes:
        source = pick_source(folder, extensions)
        if source is None:
            continue
        times = collect_times(
            label, command, source, param, folder, extra, batch
        )
        if not times:
            continue
        mid = statistics.median(times)
        err = statistics.stdev(times) if len(times) >= 2 else None
        results[label] = (mid, err)
        cv = sample_cv(times)
        if cv is not None and cv >= CV_LIMIT:
            print(f"  note: {label} cv={cv:.1%} n={len(times)}")
    return results


def format_cell(value):
    if value is None:
        return "-"
    mid, err = value
    if err is None:
        return f"{mid:.2f}"
    return f"{mid:.2f} ± {err:.2f}"


def color_cell(plain):
    if " ± " not in plain:
        return plain
    mid, err = plain.split(" ± ", 1)
    return f"{mid}{grey(' ± ' + err)}"


def pad_cell(plain, width):
    return color_cell(plain) + " " * max(0, width - len(plain))


def display(names, rows, columns):
    langs = [name for name in columns if any(name in row for row in rows)]
    cells = []
    for results in rows:
        cells.append([format_cell(results.get(lang)) for lang in langs])

    width = max([15] + [len(n) for n in names] + [8])
    lang_width = max(
        [8]
        + [len(lang) for lang in langs]
        + [len(cell) for row in cells for cell in row],
        default=8,
    )

    header = f"{'':<{width}}"
    for lang in langs:
        header += f" {lang:<{lang_width}}"
    print(header)

    for name, row in zip(names, cells):
        line = f"{name:<{width}}"
        for cell in row:
            line += f" {pad_cell(cell, lang_width)}"
        print(line)


def display_speedup(names, rows, columns):
    """Print speedup vs the first worker in each Morpho sweep series."""
    groups = speedup_groups(columns)
    if not groups:
        return
    for kind, series in groups:
        if len(series) < 2:
            continue
        w0, col0 = series[0]
        headers = [f"sp{w}" for w, _ in series[1:]]
        cells = []
        for results in rows:
            base = results.get(col0)
            t0 = None if base is None else base[0]
            row = []
            for w, col in series[1:]:
                cell = results.get(col)
                if t0 and cell and cell[0]:
                    row.append(f"{t0 / cell[0]:.2f}")
                else:
                    row.append("-")
            cells.append(row)
        title = f"Speedup vs -w{w0}"
        if kind:
            title += f" ({kind})"
        print()
        print(title)
        width = max([15] + [len(n) for n in names] + [8])
        col_w = max([8] + [len(h) for h in headers] + [len(c) for row in cells for c in row], default=8)
        header = f"{'':<{width}}"
        for h in headers:
            header += f" {h:<{col_w}}"
        print(header)
        for name, row in zip(names, cells):
            line = f"{name:<{width}}"
            for cell in row:
                line += f" {cell:<{col_w}}"
            print(line)


def build_parser():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="Run morpho-benchmark programs in a target folder.",
        epilog="""\
Suites: clbg, language, other, problems, functionals

Examples:
  python3 tools/benchmark.py language
  python3 tools/benchmark.py problems/Cube
  python3 tools/benchmark.py functionals
  python3 tools/benchmark.py --list functionals
  python3 tools/benchmark.py -w 4 problems/Qtensor
  python3 tools/benchmark.py -w sweep functionals
  python3 tools/benchmark.py -O -w sweep functionals/Landau
  python3 tools/benchmark.py --morpho ./morpho6 -O language
  python3 tools/benchmark.py -n 1 --languages morpho functionals

-w SPEC is Morpho-only: N, sweep (1..P-1), N-M, or N,M,…
-O also times morpho with --eval "import bytecodeoptimizer" -O.
--morpho EXE uses that binary instead of morpho6 from PATH.
A sweep prints times then speedup vs -w1. -O and -w can be combined.
The runner guesses P-cores (sysctl / sysfs / EfficiencyClass, else os.cpu_count)
and warns if -w exceeds P-1.
""",
    )
    parser.add_argument(
        "folder",
        nargs="*",
        help="Suite or benchmark folder (e.g. clbg, language, problems/Adhesion)",
    )
    parser.add_argument(
        "-n",
        "--samples",
        type=int,
        default=SAMPLES,
        help=f"runs per batch (default: {SAMPLES}); a second batch is added if stdev/mean >= 1%%",
    )
    parser.add_argument(
        "--languages",
        metavar="CMD[,CMD...]",
        help="restrict to these interpreter commands (e.g. morpho,python3,lua)",
    )
    parser.add_argument(
        "--morpho",
        metavar="EXE",
        help="Morpho executable (default: morpho6 from PATH)",
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="show detected languages and benchmarks without running them",
    )
    parser.add_argument(
        "-O",
        "--optimize",
        action="store_true",
        help='also time morpho with --eval "import bytecodeoptimizer" -O',
    )
    parser.add_argument(
        "-w",
        "--workers",
        type=parse_workers,
        metavar="SPEC",
        help="pass -wN to morpho: N, sweep (1..P-1), N-M, or N,M,… (ignored for other languages)",
    )
    return parser


def main():
    parser = build_parser()
    args = parser.parse_args()
    if not args.folder:
        parser.print_help()
        return 0
    if args.samples < 1:
        print("error: --samples must be at least 1", file=sys.stderr)
        return 2

    lang_filter = None
    if args.languages:
        lang_filter = [item.strip() for item in args.languages.split(",") if item.strip()]
        if not lang_filter:
            print("error: --languages is empty", file=sys.stderr)
            return 2

    pcores, psrc = performance_core_guess()
    wlimit = soft_worker_limit(pcores)
    workers = args.workers
    if workers == SWEEP_SENTINEL:
        if wlimit is None:
            print(
                "error: -w sweep needs a CPU count (sysctl, sysfs, or os.cpu_count)",
                file=sys.stderr,
            )
            return 2
        workers = list(range(1, wlimit + 1))

    try:
        detected = detect_runtimes(lang_filter, morpho=args.morpho)
    except FileNotFoundError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2
    if not detected:
        print("error: no supported language interpreters found on PATH", file=sys.stderr)
        return 1

    print("Detected languages: " + ", ".join(name for name, _, _ in detected))
    if pcores is not None:
        logical = os.cpu_count()
        host = f"Host CPUs: {pcores} P-cores ({psrc})"
        if logical and logical != pcores:
            host += f", {logical} logical"
        print(host)
    if args.morpho:
        morpho_runtime = next(
            (path for name, path, _ in detected if is_morpho(name)), None
        )
        if morpho_runtime:
            print(f"Morpho executable: {morpho_runtime}")
    if args.optimize:
        print('Morpho optimization: also running with --eval "import bytecodeoptimizer" -O')
    if workers is not None:
        if len(workers) == 1:
            print(f"Morpho workers: -w{workers[0]}")
        else:
            print("Morpho workers: " + ", ".join(f"-w{w}" for w in workers))
        if wlimit is not None:
            over = sorted({w for w in workers if w > wlimit})
            if over:
                shown = ", ".join(f"-w{w}" for w in over)
                verb = "exceeds" if len(over) == 1 else "exceed"
                sys.stdout.flush()
                print(
                    f"warning: {shown} {verb} guessed P-cores-1 "
                    f"({wlimit} from {psrc}); extra workers may land on "
                    f"efficiency cores",
                    file=sys.stderr,
                )

    runtimes = expand_runtimes(
        detected, args.optimize, workers=None if args.list else workers
    )
    labels = [label for label, _, _, _ in runtimes]

    benches = []
    for folder in args.folder:
        try:
            benches.extend(discover(folder, known_extensions()))
        except FileNotFoundError as exc:
            print(f"error: {exc}", file=sys.stderr)
            return 2

    # Preserve order, drop duplicates
    seen = set()
    unique = []
    for bench in benches:
        if bench in seen:
            continue
        seen.add(bench)
        unique.append(bench)
    benches = unique

    if not benches:
        print("error: no benchmark programs found in the given folder(s)", file=sys.stderr)
        return 1

    if args.list:
        print("Benchmarks:")
        for bench in benches:
            present = []
            for label, _, exts, _ in runtimes:
                if pick_source(bench, exts):
                    present.append(label)
            extra = f"  [{', '.join(present)}]" if present else ""
            print(f"  {bench.name}{extra}")
        return 0

    print("--Begin testing---------------------")
    rows = []
    names = []
    for bench in benches:
        rows.append(benchmark(bench, runtimes, args.samples))
        names.append(bench.name)
    print()
    display(names, rows, labels)
    if workers is not None and len(workers) > 1:
        display_speedup(names, rows, labels)
    print("--End testing-----------------------")
    return 0


if __name__ == "__main__":
    sys.exit(main())
