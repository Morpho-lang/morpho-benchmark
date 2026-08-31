local obj = { a = 5 }
function obj:report()
  return self.a
end

local m = obj.report
local y = 0
for i = 1, 60000000 do
  y = m(obj)
end
io.write(y .. "\n")
