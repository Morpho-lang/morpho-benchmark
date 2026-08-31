# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# contributed by jose fco. gonzalez
# modified by Sokolov Yura
#
# Sequence THREE is generated with the fasta PRNG (same seed, after
# the IUB draws) so the common runner can pass N instead of piping stdin.

IM = 139968
IA = 3877
IC = 29573
$seed = 42

HOMO_P = [
  0.3029549426680,
  0.1979883004921,
  0.1975473066391,
  0.3015094502008
]
HOMO = "ACGT"

def fasta_rand(maxv)
  $seed = ($seed * IA + IC) % IM
  maxv * $seed / IM
end

def make_three(n)
  (n * 3).times { fasta_rand(1.0) }
  out = String.new
  (n * 5).times do
    v = fasta_rand(1.0)
    j = 0
    4.times do |k|
      v -= HOMO_P[k]
      j = k
      break if v < 0
    end
    out << HOMO[j]
  end
  out
end

def frequency(seq, length)
  ns = seq.length + 1 - length
  table = Hash.new(0)
  (0...ns).each do |i|
    table[seq[i, length]] += 1
  end
  [ns, table]
end

def sort_by_freq(seq, length)
  n, table = frequency(seq, length)
  table.sort { |a, b|
    cmp = b[1] <=> a[1]
    cmp == 0 ? a[0] <=> b[0] : cmp
  }.each do |k, v|
    puts "%s %.3f" % [k, (v * 100).to_f / n]
  end
  puts
end

def find_seq(seq, s)
  n, table = frequency(seq, s.length)
  puts "#{table[s]}\t#{s}"
end

n = (ARGV[0] || 1000).to_i
seq = make_three(n)
[1, 2].each { |i| sort_by_freq(seq, i) }
%w(GGT GGTA GGTATT GGTATTTTAATT GGTATTTTAATTTATAGT).each { |s| find_seq(seq, s) }
