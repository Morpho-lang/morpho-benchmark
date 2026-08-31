local function f(x)
  return x
end

local y = 0
for i = 0, 69999999 do
  y = f(i)
end
io.write(y .. "\n")
