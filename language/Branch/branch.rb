k = 0
35_000_000.times do |i|
  if i % 2 == 0
    k += 1
  else
    k += 2
  end
end
puts k
