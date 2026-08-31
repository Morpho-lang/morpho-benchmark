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
import subprocess
import sys
import time
from pathlib import Path

SAMPLES = 5
CV_LIMIT = 0.01

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

# morpho6 -O enables optimization once bytecodeoptimizer is imported.
MORPHO_OPTIMIZE_ARGS = ("-O", "--eval", "import bytecodeoptimizer")


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


def expand_runtimes(runtimes, optimize):
    """Turn detected interpreters into runnable variants.

    With -O, each morpho interpreter is included twice: once as-is and once
    with -O --eval "import bytecodeoptimizer".
    """
    expanded = []
    for name, command, extensions in runtimes:
        expanded.append((name, command, extensions, []))
        if optimize and is_morpho(name):
            expanded.append(
                ("morpho -O", command, extensions, list(MORPHO_OPTIMIZE_ARGS))
            )
    return expanded


def matches_filter(name, only):
    """True if name is selected. Prefixes work: python → python3.12, morpho → morpho6."""
    if only is None:
        return True
    return any(name == item or name.startswith(item) for item in only)


def detect_runtimes(only=None):
    """Return [(name, command_path, extensions), ...] for commands on PATH."""
    seen = set()
    found = []
    for name, exts in CANDIDATES:
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


def has_sources(folder, extensions):
    if not folder.is_dir() or folder.name in SKIP_DIRS or folder.name.startswith("."):
        return False
    return any(is_source(p, extensions) for p in folder.iterdir())


def discover(target, extensions):
    """Find benchmark directories under target.

    A suite folder (e.g. clbg/) yields its immediate children that contain
    sources. A single benchmark folder is used as-is. The repository root
    expands one extra level so every suite is included.
    """
    target = Path(target).resolve()
    if not target.is_dir():
        raise FileNotFoundError(f"Not a directory: {target}")

    children = sorted(
        p
        for p in target.iterdir()
        if p.is_dir() and not p.name.startswith(".") and p.name not in SKIP_DIRS
    )
    benches = [p for p in children if has_sources(p, extensions)]
    if benches:
        return benches
    if has_sources(target, extensions):
        return [target]

    deeper = []
    for child in children:
        deeper.extend(
            p
            for p in sorted(child.iterdir())
            if p.is_dir() and has_sources(p, extensions)
        )
    return deeper


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


def run(name, command, source, param, cwd, extra=None):
    extra = extra or []
    shown = [name, source.name]
    cmd = [command, *extra, source.name]
    if param is not None:
        shown.append(param)
        cmd.append(param)

    print(" ".join(shown))
    start = time.perf_counter()
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except OSError:
        return None
    elapsed = time.perf_counter() - start
    if result.returncode != 0:
        return None
    return elapsed


def run_batch(label, command, source, param, folder, extra, count):
    times = []
    failures = 0
    while len(times) < count and failures < count:
        elapsed = run(label, command, source, param, folder, extra=extra)
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


def parse_args():
    parser = argparse.ArgumentParser(
        description="Run morpho-benchmark programs in a target folder."
    )
    parser.add_argument(
        "folder",
        nargs="+",
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
        "--list",
        action="store_true",
        help="show detected languages and benchmarks without running them",
    )
    parser.add_argument(
        "-O",
        "--optimize",
        action="store_true",
        help='also time morpho with -O --eval "import bytecodeoptimizer"',
    )
    return parser.parse_args()


def main():
    args = parse_args()
    if args.samples < 1:
        print("error: --samples must be at least 1", file=sys.stderr)
        return 2

    lang_filter = None
    if args.languages:
        lang_filter = [item.strip() for item in args.languages.split(",") if item.strip()]
        if not lang_filter:
            print("error: --languages is empty", file=sys.stderr)
            return 2

    runtimes = expand_runtimes(detect_runtimes(lang_filter), args.optimize)
    if not runtimes:
        print("error: no supported language interpreters found on PATH", file=sys.stderr)
        return 1

    labels = [label for label, _, _, _ in runtimes]
    print("Detected languages: " + ", ".join(labels))
    if args.optimize:
        print('Morpho optimization: also running with -O --eval "import bytecodeoptimizer"')

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
    print("--End testing-----------------------")
    return 0


if __name__ == "__main__":
    sys.exit(main())
