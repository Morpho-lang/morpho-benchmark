# morpho-benchmark

This repository includes a variety of programs to assist in benchmarking [morpho](https://github.com/Morpho-lang/morpho)'s performance. The tests are divided into several folders:

* clbg - Benchmarks from the [Computer Language Benchmark Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/index.html), intended to compare morpho to other languages on similar test problems.

* language - Benchmarks for various language features, with equivalent implementations in other dynamic languages.

* other - Interesting programs with real workflows, with equivalent implementations in other languages.

* problems - Shape optimization problems that aim to represent typical morpho use cases.

* functionals - Morpho-only functional map kernels (`total` / `gradient` / `fieldgradient`) intended to test performance of the `geometry` package.

Where relevant, implementations are provided in Python, Lua, wren, Ruby and Perl. 

## Running benchmarks

Use the common runner in `tools/benchmark.py`, pointing it at a suite or a single benchmark folder:

```
python3 tools/benchmark.py clbg
python3 tools/benchmark.py language
python3 tools/benchmark.py problems/Adhesion
python3 tools/benchmark.py functionals
python3 tools/benchmark.py -w 4 problems/Cube
python3 tools/benchmark.py -w sweep functionals
```

The script detects which interpreters are installed and which language implementations are present in the target, and only runs those combinations. Distinct Python versions on `PATH` (e.g. `python3.12` and `python3.14`) are timed separately. `--morpho EXE` uses that Morpho binary instead of `morpho6` from `PATH`. Discovery is recursive (skipping `tools/` and hidden directories). If a benchmark folder contains `in.txt`, the first line is passed as a command-line argument (used by the CLBG programs).

Each program is run 5 times (change with `-n`). If the sample standard deviation is still 1% or more of the mean, a second batch of 5 is run. The table reports the median wall-clock time ± sample standard deviation.

```
python3 tools/benchmark.py --help
python3 tools/benchmark.py --list clbg
python3 tools/benchmark.py -O language
```

## Command-line flags

* `-O` also times morpho with optimization enabled, requiring the [bytecode optimizer](https://github.com/Morpho-lang/morpho-bytecodeoptimizer). Morpho is run with `--eval "import bytecodeoptimizer" -O`.
* `--workers` / `-w` runs morpho in parallel mode:
    - `-w X` uses that many workers.
    - `-w sweep`, `-w 1-7`, or `-w 1,4,7` run a sweep of worker counts. For `sweep`, the runner guesses `N` (performance cores) and times `-w1` through `-w(N-1)`. It warns if you ask for more than `N-1`.

