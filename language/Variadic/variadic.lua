local function f(...)
  return select("#", ...)
end

local y = 0
for i = 0, 13999999 do
  y = f(i, 1, 2)
end
io.write(y .. "\n")
