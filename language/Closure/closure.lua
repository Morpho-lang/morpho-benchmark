local c = 1
local function f()
  return c
end

local y = 0
for i = 1, 70000000 do
  y = f()
end
io.write(y .. "\n")
