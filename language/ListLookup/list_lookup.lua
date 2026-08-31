local N = 8000000
local a = {1, 2, 3}
local k = 0

for i = 1, N do
  local b = a[1]
  local c = a[2]
  local d = a[3]
  local e = a[1]
  local f = a[2]
  local g = a[3]
  k = k + 1
end

io.write(k .. "\n")
