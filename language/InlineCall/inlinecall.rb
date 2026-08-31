def add(x, y)
  x + y
end

y = 0
45_000_000.times { |i| y = add(i, 1) }
puts y
