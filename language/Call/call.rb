def f(x)
  x
end

y = 0
70_000_000.times { |i| y = f(i) }
puts y
