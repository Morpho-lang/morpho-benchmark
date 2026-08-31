local y = 1.0
for i = 1, 50000000 do
  y = 1.00001 * y
end
io.write(y .. "\n")
