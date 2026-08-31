y = 1.0
i = 0
while i < 50_000_000
  y = 1.00001 * y
  i += 1
end
puts y
