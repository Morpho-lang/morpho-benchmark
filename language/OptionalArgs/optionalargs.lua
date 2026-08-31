local function f(x, y)
  y = y or 1
  return x + y
end

local z = 0
for i = 0, 49999999 do
  z = f(i)
end
io.write(z .. "\n")
