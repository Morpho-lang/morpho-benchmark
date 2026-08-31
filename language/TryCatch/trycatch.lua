local k = 0
for i = 1, 30000000 do
  local ok = pcall(function()
    k = k + 1
  end)
  if not ok then
    k = k
  end
end
io.write(k .. "\n")
