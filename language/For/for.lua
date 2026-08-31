local list = {}
for i = 0, 19999999 do
  list[i + 1] = i
end

local sum = 0
for i = 1, #list do
  sum = sum + list[i]
end
io.write(sum .. "\n")
