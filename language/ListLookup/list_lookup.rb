N = 8_000_000
a = [1, 2, 3]
k = 0

N.times do
  b = a[0]
  c = a[1]
  d = a[2]
  e = a[0]
  f = a[1]
  g = a[2]
  k += 1
end

puts k
