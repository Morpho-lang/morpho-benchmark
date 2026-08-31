def f(x, y = 1)
  x + y
end

z = 0
50_000_000.times { |i| z = f(i) }
puts z
