local y = 1.0
local i = 0
while i < 50000000 do
  y = 1.00001 * y
  i = i + 1
end
io.write(y .. "\n")
