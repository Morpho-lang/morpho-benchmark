-- Cast rays at a sphere and shade the intersection.

local function shade(px, py)
  local ox = 0.0
  local oy = 0.0
  local oz = -3.0

  local dx = px
  local dy = py
  local dz = 1.0

  local cx = 0.0
  local cy = 0.0
  local cz = 0.0
  local r = 1.0

  local ocx = ox - cx
  local ocy = oy - cy
  local ocz = oz - cz

  local a = dx * dx + dy * dy + dz * dz
  local b = 2.0 * (ocx * dx + ocy * dy + ocz * dz)
  local c = ocx * ocx + ocy * ocy + ocz * ocz - r * r

  local disc = b * b - 4.0 * a * c

  if disc < 0.0 then
    return 0.05
  end

  local brightness = disc / (1.0 + disc)

  if brightness > 0.5 then
    return brightness
  end
  return 0.25 * brightness
end

local function benchmark(width, height, reps)
  local checksum = 0.0
  local r = 0
  while r < reps do
    local j = 0
    while j < height do
      local i = 0
      while i < width do
        local px = -1.0 + 2.0 * i / (width - 1)
        local py = -0.75 + 1.5 * j / (height - 1)
        local s = shade(px, py)
        checksum = checksum + s * (1.0 + 0.0001 * i + 0.00001 * j)
        i = i + 1
      end
      j = j + 1
    end
    r = r + 1
  end
  return checksum
end

print(benchmark(240, 180, 210))
