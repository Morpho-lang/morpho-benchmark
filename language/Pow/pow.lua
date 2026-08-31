local N = 17000000

local function sphere(x, y, z)
  return x^2 + y^2 + z^2
end

for i = 1, N do
  sphere(0.1, 0.2, 0.3)
end
