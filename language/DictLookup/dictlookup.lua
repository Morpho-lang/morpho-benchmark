local N = 10000000
local d = { a = 1, b = 2, c = 3 }
local k = 0

for i = 1, N do
  local b = d.a
  local c = d.b
  local e = d.c
  local f = d.a
  local g = d.b
  local h = d.c
  k = k + 1
end

io.write(k .. "\n")
