local N = 3000000
local M = 10

local function sqr(x)
  return x * x
end

for k = 1, N do
  for i = 1, M do
    sqr(0.1)
  end
end
