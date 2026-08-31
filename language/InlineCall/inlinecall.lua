local function add(x, y)
  return x + y
end

local y = 0
for i = 0, 44999999 do
  y = add(i, 1)
end
io.write(y .. "\n")
