# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# submitted by Ian Osgood
# modified by Sokolov Yura
# modified by bearophile
# 2to3
#
# Sequence THREE is generated with the fasta PRNG (same seed, after
# the IUB draws) so the common runner can pass N instead of piping stdin.

from sys import argv

IM = 139968
IA = 3877
IC = 29573
seed = 42

HOMO_P = [
    0.3029549426680,
    0.1979883004921,
    0.1975473066391,
    0.3015094502008
]
HOMO = "ACGT"


def fasta_rand(maxv):
    global seed
    seed = (seed * IA + IC) % IM
    return maxv * seed / IM


def make_three(n):
    for _ in range(n * 3):
        fasta_rand(1.0)
    out = []
    for _ in range(n * 5):
        v = fasta_rand(1.0)
        j = 0
        for j in range(4):
            v -= HOMO_P[j]
            if v < 0:
                break
        out.append(HOMO[j])
    return "".join(out)


def gen_freq(seq, frame, frequences):
    ns = len(seq) + 1 - frame
    frequences.clear()
    for ii in range(ns):
        nucleo = seq[ii:ii + frame]
        if nucleo in frequences:
            frequences[nucleo] += 1
        else:
            frequences[nucleo] = 1
    return ns, frequences


def sort_seq(seq, length, frequences):
    n, frequences = gen_freq(seq, length, frequences)
    rows = sorted(
        frequences.items(),
        key=lambda seq_freq: (-seq_freq[1], seq_freq[0]),
    )
    print("\n".join("%s %.3f" % (st, 100.0 * fr / n) for st, fr in rows))
    print()


def find_seq(seq, s, frequences):
    n, t = gen_freq(seq, len(s), frequences)
    print("%d\t%s" % (t.get(s, 0), s))


def main(n):
    sequence = make_three(n)
    frequences = {}
    for nl in 1, 2:
        sort_seq(sequence, nl, frequences)
    for se in "GGT GGTA GGTATT GGTATTTTAATT GGTATTTTAATTTATAGT".split():
        find_seq(sequence, se, frequences)


if __name__ == "__main__":
    main(int(argv[1]) if len(argv) > 1 else 1000)
