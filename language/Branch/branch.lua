local k = 0
for i = 0, 34999999 do
  if i % 2 == 0 then
    k = k + 1
  else
    k = k + 2
  end
end
io.write(k .. "\n")
