local obj = { a = 5 }
local y = 0
for i = 1, 70000000 do
  y = obj.a
end
io.write(y .. "\n")
