local list = {}
for i = 0, 29999999 do
  list[#list + 1] = i
end
io.write(#list .. "\n")
