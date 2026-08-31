# Computer Language Benchmarks Game

This folder contains implementations of the [Computer Language Benchmark Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/index.html) test programs in morpho. Implementations in other languages were selected to be relatively similar to the same implementation style. Run them with the common runner:

```
python3 tools/benchmark.py clbg
```

All files derived from CLBG are subject to the BSD license provided in the original (see LICENSE file). The new .morpho files are (c) T J Atherton, but provided under the same license.

## Example results

These results are from a 1.1Ghz quad core Intel i5 Macbook Air 2020. They represent an earlier output of `tools/benchmark.py` (shortest of 10 runs). The runner now reports median ± sample standard deviation.

                    morpho6  python3.9 python3.12 lua      ruby     perl    
    BinaryTrees     1.54     3.64     1.68     0.65     0.98     1.13    
    NBody           1.58     1.99     0.87     0.27     0.58     0.57    
    TooSimple       0.57     1.39     1.27     -        0.9      -       
    Mandelbrot      1.08     1.77     1.19     0.21     0.42     0.48    
    Fasta           0.79     0.93     0.62     0.07     0.58     0.17    
    SpectralNorm    1.42     2.55     1.8      0.37     0.79     0.45    
    Fannkuch        1.47     2.01     0.78     0.18     0.45     0.63   

## Future work

k-nucleotide is included. Sequence THREE is generated from the fasta PRNG (argument `N` in `in.txt`) rather than read from stdin, because the runner passes a command-line argument rather than piping a FASTA file. Morpho uses `substring` and `Dictionary`; it has no `toupper` and cannot compare strings with `<`, so the sequence is generated in uppercase and key-tie sorting uses A/C/G/T codes.

Still omitted:

* regex-redux (no regular expressions; we intend to wrap an external library)
* reverse-complement (stdin/binary-ish FASTA I/O and case conversion)
* pidigits (arbitrary-precision integers)

Additionally, running some tests at full CLBG length requires iteration counts larger than morpho's standard int32 type.

We also note a few desirable future features for morpho and its library:

* Easy constructors for empty lists
