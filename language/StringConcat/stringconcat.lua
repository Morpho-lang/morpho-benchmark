local a = "hello"
local b = "world"
local y = ""
for i = 1, 20000000 do
  y = a .. b
end
io.write(y .. "\n")
