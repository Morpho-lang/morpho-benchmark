-- Iterate the Mandelbrot map z -> z^2+c until the orbit escapes or hits the iteration limit.

local function mandel(cx, cy, maxiter)
  local x = 0.0
  local y = 0.0
  local i = 0
  while i < maxiter do
    local xx = x * x
    local yy = y * y
    if xx + yy > 4.0 then
      return i
    end
    local xy = x * y
    y = 2.0 * xy + cy
    x = xx - yy + cx
    i = i + 1
  end
  return maxiter
end

local function benchmark(width, height, maxiter, reps)
  local checksum = 0
  local r = 0
  while r < reps do
    local j = 0
    while j < height do
      local i = 0
      while i < width do
        local cx = -2.0 + 3.0 * i / (width - 1)
        local cy = -1.25 + 2.5 * j / (height - 1)
        local n = mandel(cx, cy, maxiter)
        checksum = checksum + n * (i + 1) + j + r
        i = i + 1
      end
      j = j + 1
    end
    r = r + 1
  end
  return checksum
end

print(benchmark(160, 120, 64, 80))
