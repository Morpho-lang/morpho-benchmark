N = 3_000_000
M = 10

def sqr(x)
  x * x
end

(1..N).each do
  (1..M).each { sqr(0.1) }
end
