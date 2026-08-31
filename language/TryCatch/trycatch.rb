k = 0
30_000_000.times do
  begin
    k += 1
  rescue StandardError
    k = k
  end
end
puts k
