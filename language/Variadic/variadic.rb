def f(*v)
  v.length
end

y = 0
14_000_000.times { |i| y = f(i, 1, 2) }
puts y
