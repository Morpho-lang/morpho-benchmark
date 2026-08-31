-- The Computer Language Benchmarks Game
-- https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
--
-- Hashtable / k-mer counting after Mike Pall's knucleotide Lua #2.
-- Sequence THREE is generated with the fasta PRNG (same seed, after
-- the IUB draws) so the common runner can pass N instead of piping stdin.

local IM, IA, IC = 139968, 3877, 29573
local seed = 42

local HOMO_P = {
  0.3029549426680,
  0.1979883004921,
  0.1975473066391,
  0.3015094502008
}
local HOMO = "ACGT"

local function fasta_rand(maxv)
  seed = (seed * IA + IC) % IM
  return maxv * seed / IM
end

local function make_three(n)
  for _ = 1, n * 3 do
    fasta_rand(1.0)
  end
  local out = {}
  for i = 1, n * 5 do
    local v = fasta_rand(1.0)
    local j = 1
    for k = 1, 4 do
      v = v - HOMO_P[k]
      j = k
      if v < 0 then break end
    end
    out[i] = string.sub(HOMO, j, j)
  end
  return table.concat(out)
end

local function gen_freq(seq, frame)
  local freq = {}
  local ns = #seq + 1 - frame
  for i = 1, ns do
    local nucleo = string.sub(seq, i, i + frame - 1)
    freq[nucleo] = (freq[nucleo] or 0) + 1
  end
  return ns, freq
end

local function sort_seq(seq, k)
  local n, freq = gen_freq(seq, k)
  local keys = {}
  local sn = 0
  for c, _ in pairs(freq) do
    sn = sn + 1
    keys[sn] = c
  end
  table.sort(keys, function(a, b)
    local fa, fb = freq[a], freq[b]
    if fa == fb then return a < b end
    return fa > fb
  end)
  for _, c in ipairs(keys) do
    io.write(string.format("%s %0.3f\n", c, (freq[c] * 100) / n))
  end
  io.write("\n")
end

local function find_seq(seq, s)
  local _, freq = gen_freq(seq, #s)
  io.write(freq[s] or 0, "\t", s, "\n")
end

local n = tonumber(arg[1]) or 1000
local seq = make_three(n)
sort_seq(seq, 1)
sort_seq(seq, 2)
find_seq(seq, "GGT")
find_seq(seq, "GGTA")
find_seq(seq, "GGTATT")
find_seq(seq, "GGTATTTTAATT")
find_seq(seq, "GGTATTTTAATTTATAGT")
