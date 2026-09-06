#!/usr/bin/env python3
# Full-suite runner for regression detection
# T J Atherton 2026

"""Run every morpho-benchmark suite through tools/benchmark.py.

Two passes, both with -O so unoptimized and optimized Morpho share a table:

  problems + functionals  — also -w sweep (worker scaling)
  clbg + language + other — language comparison, no worker columns

Use this as the authoritative complete run when checking a new Morpho build.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
import time
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
BENCHMARK = Path(__file__).resolve().parent / "benchmark.py"

SCALE_SUITES = ("problems", "functionals")
COMPARE_SUITES = ("clbg", "language", "other")


def banner(text):
    print()
    print(text)
    print()
    sys.stdout.flush()


def run_phase(label, args):
    """Run benchmark.py; return its exit code."""
    banner(f"-- {label} ---------------------")
    print(" ".join(["tools/benchmark.py", *args]))
    sys.stdout.flush()
    result = subprocess.run([sys.executable, str(BENCHMARK), *args], cwd=REPO)
    return result.returncode


def build_parser():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="Run the complete morpho-benchmark suite for regression checks.",
        epilog="""\
Passes:
  problems functionals   -O -w sweep
  clbg language other    -O

Examples:
  python3 tools/runall.py
  python3 tools/runall.py --morpho ./morpho6
  python3 tools/runall.py -n 1 --languages morpho
  python3 tools/runall.py --list

Flags are forwarded to each benchmark.py pass. -O is always on. -w applies
only to problems and functionals (default: sweep).
""",
    )
    parser.add_argument(
        "-n",
        "--samples",
        type=int,
        help="runs per batch (default: benchmark.py default)",
    )
    parser.add_argument(
        "--languages",
        metavar="CMD[,CMD...]",
        help="restrict to these interpreter commands (e.g. morpho,python3)",
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
        "-w",
        "--workers",
        metavar="SPEC",
        default="sweep",
        help="worker spec for problems/functionals (default: sweep)",
    )
    return parser


def common_args(args):
    extra = []
    if args.samples is not None:
        extra.extend(["-n", str(args.samples)])
    if args.languages:
        extra.extend(["--languages", args.languages])
    if args.morpho:
        extra.extend(["--morpho", args.morpho])
    if args.list:
        extra.append("--list")
    extra.append("-O")
    return extra


def missing_suites(names):
    return [name for name in names if not (REPO / name).is_dir()]


def main():
    parser = build_parser()
    args = parser.parse_args()
    if args.samples is not None and args.samples < 1:
        print("error: --samples must be at least 1", file=sys.stderr)
        return 2
    if not BENCHMARK.is_file():
        print(f"error: runner not found: {BENCHMARK}", file=sys.stderr)
        return 2

    scale_missing = missing_suites(SCALE_SUITES)
    compare_missing = missing_suites(COMPARE_SUITES)
    missing = scale_missing + compare_missing
    if missing:
        print(
            "error: suite folder(s) not found: " + ", ".join(missing),
            file=sys.stderr,
        )
        return 2

    shared = common_args(args)
    start = time.perf_counter()
    print("Complete morpho-benchmark run")
    print(f"Repository: {REPO}")

    codes = []
    codes.append(
        run_phase(
            "Scale: problems, functionals (-O -w sweep)"
            if args.workers == "sweep"
            else f"Scale: problems, functionals (-O -w {args.workers})",
            [*shared, "-w", args.workers, *SCALE_SUITES],
        )
    )
    codes.append(
        run_phase(
            "Compare: clbg, language, other (-O)",
            [*shared, *COMPARE_SUITES],
        )
    )

    elapsed = time.perf_counter() - start
    failed = [c for c in codes if c]
    status = 0 if not failed else failed[0]
    banner(
        f"-- Done ({elapsed:.0f}s, exit {status}) ----------------"
    )
    return status


if __name__ == "__main__":
    sys.exit(main())
