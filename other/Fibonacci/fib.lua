-- Recursively compute Fibonacci numbers.

local function f(x)
  if x < 2 then return x end
  return f(x - 1) + f(x - 2)
end

for i = 1, 100 do
  print(f(28))
end
