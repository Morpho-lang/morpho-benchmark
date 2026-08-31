// The Computer Language Benchmarks Game
// https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
//
// Hashtable / k-mer counting, transliterated from the Python #1 / Ruby #2
// programs. Sequence THREE is generated with the fasta PRNG (same seed,
// after the IUB draws) so the common runner can pass N instead of piping stdin.

import "os" for Process

var IM = 139968
var IA = 3877
var IC = 29573
var seed = 42

var HOMO_P = [
  0.3029549426680,
  0.1979883004921,
  0.1975473066391,
  0.3015094502008
]
var HOMO = "ACGT"

var fastaRand = Fn.new { |maxv|
  seed = (seed * IA + IC) % IM
  return maxv * seed / IM
}

var makeThree = Fn.new { |n|
  var i = 0
  while (i < n * 3) {
    fastaRand.call(1.0)
    i = i + 1
  }
  var out = []
  i = 0
  while (i < n * 5) {
    var v = fastaRand.call(1.0)
    var j = 0
    var k = 0
    while (k < 4) {
      v = v - HOMO_P[k]
      j = k
      if (v < 0) break
      k = k + 1
    }
    out.add(HOMO[j])
    i = i + 1
  }
  return out.join()
}

var fmt3 = Fn.new { |x|
  var scaled = (x * 1000 + 0.5).floor
  var ip = (scaled / 1000).floor
  var fp = scaled % 1000
  var fs = fp.toString
  while (fs.count < 3) fs = "0" + fs
  return ip.toString + "." + fs
}

var strcmp = Fn.new { |a, b|
  var ba = a.bytes
  var bb = b.bytes
  var i = 0
  var n = ba.count
  var m = bb.count
  while (i < n && i < m) {
    if (ba[i] != bb[i]) return ba[i] - bb[i]
    i = i + 1
  }
  return n - m
}

var genFreq = Fn.new { |seq, frame|
  var freq = {}
  var ns = seq.count + 1 - frame
  var ii = 0
  while (ii < ns) {
    var nucleo = seq[ii...(ii + frame)]
    if (freq.containsKey(nucleo)) {
      freq[nucleo] = freq[nucleo] + 1
    } else {
      freq[nucleo] = 1
    }
    ii = ii + 1
  }
  return [ns, freq]
}

var sortSeq = Fn.new { |seq, length|
  var pair = genFreq.call(seq, length)
  var n = pair[0]
  var freq = pair[1]
  var rows = []
  for (k in freq.keys) {
    rows.add([k, freq[k]])
  }
  rows.sort { |a, b|
    if (a[1] != b[1]) return a[1] > b[1]
    return strcmp.call(a[0], b[0]) < 0
  }
  for (row in rows) {
    System.print("%(row[0]) %(fmt3.call(100.0 * row[1] / n))")
  }
  System.print("")
}

var findSeq = Fn.new { |seq, s|
  var pair = genFreq.call(seq, s.count)
  var t = pair[1]
  var c = t.containsKey(s) ? t[s] : 0
  System.print("%(c)\t%(s)")
}

var n = 1000
if (Process.arguments.count > 0) n = Num.fromString(Process.arguments[0])

var sequence = makeThree.call(n)
sortSeq.call(sequence, 1)
sortSeq.call(sequence, 2)
for (se in ["GGT", "GGTA", "GGTATT", "GGTATTTTAATT", "GGTATTTTAATTTATAGT"]) {
  findSeq.call(sequence, se)
}
