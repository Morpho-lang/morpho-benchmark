# morpho-benchmarks

This folder includes a variety of programs to assist in benchmarking [morpho](https://github.com/Morpho-lang/morpho)'s performance. The tests are divided into several folders:

* clbg - Benchmarks from the [Computer Language Benchmark Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/index.html), intended to compare morpho to other languages on similar test problems.

* language - Benchmarks for language features.

* other - Interesting problems, some of which are provided in multiple languages.

* problems - Shape optimization problems that aim to represent typical morpho use cases.

## Running benchmarks

Use the common runner in `tools/benchmark.py`, pointing it at a suite or a single benchmark folder:

```
python3 tools/benchmark.py clbg
python3 tools/benchmark.py language
python3 tools/benchmark.py problems/Adhesion
```

The script detects which interpreters are installed and which language implementations are present in the target, and only runs those combinations. Distinct Python versions on `PATH` (e.g. `python3.12` and `python3.14`) are timed separately. If a benchmark folder contains `in.txt`, the first line is passed as a command-line argument (used by the CLBG programs).

Each program is run 5 times (change with `-n`). If the sample standard deviation is still 1% or more of the mean, a second batch of 5 is run. The table reports the median wall-clock time ± sample standard deviation.

```
python3 tools/benchmark.py --help
python3 tools/benchmark.py --list clbg
python3 tools/benchmark.py -O language
```

The `-O` flag also times morpho with `-O --eval "import bytecodeoptimizer"`, reported as a `morpho -O` column next to the unoptimized run.
