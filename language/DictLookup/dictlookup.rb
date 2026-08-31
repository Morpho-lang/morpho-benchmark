N = 10_000_000
d = { "a" => 1, "b" => 2, "c" => 3 }
k = 0

N.times do
  b = d["a"]
  c = d["b"]
  e = d["c"]
  f = d["a"]
  g = d["b"]
  h = d["c"]
  k += 1
end

puts k
