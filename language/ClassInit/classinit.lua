local Foo = {}
Foo.__index = Foo

function Foo.new()
  return setmetatable({ x = 1 }, Foo)
end

local o = Foo.new()
for i = 1, 15000000 do
  o = Foo.new()
end
io.write(o.x .. "\n")
