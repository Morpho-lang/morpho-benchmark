-- Integrate a 3-body gravitational system with fourth-order Runge-Kutta.

local function accelx(x, y, ox, oy, mass)
  local dx = ox - x
  local dy = oy - y
  local r2 = dx * dx + dy * dy + 0.01
  local invr = 1.0 / math.sqrt(r2)
  local invr3 = invr * invr * invr
  return mass * dx * invr3
end

local function accely(x, y, ox, oy, mass)
  local dx = ox - x
  local dy = oy - y
  local r2 = dx * dx + dy * dy + 0.01
  local invr = 1.0 / math.sqrt(r2)
  local invr3 = invr * invr * invr
  return mass * dy * invr3
end

local function step(dt,
                    x1, y1, vx1, vy1,
                    x2, y2, vx2, vy2,
                    x3, y3, vx3, vy3)

  local m1 = 1.0
  local m2 = 0.8
  local m3 = 0.6

  local ax1 = accelx(x1, y1, x2, y2, m2) + accelx(x1, y1, x3, y3, m3)
  local ay1 = accely(x1, y1, x2, y2, m2) + accely(x1, y1, x3, y3, m3)

  local ax2 = accelx(x2, y2, x1, y1, m1) + accelx(x2, y2, x3, y3, m3)
  local ay2 = accely(x2, y2, x1, y1, m1) + accely(x2, y2, x3, y3, m3)

  local ax3 = accelx(x3, y3, x1, y1, m1) + accelx(x3, y3, x2, y2, m2)
  local ay3 = accely(x3, y3, x1, y1, m1) + accely(x3, y3, x2, y2, m2)

  local k1x1 = vx1
  local k1y1 = vy1
  local k1vx1 = ax1
  local k1vy1 = ay1

  local k1x2 = vx2
  local k1y2 = vy2
  local k1vx2 = ax2
  local k1vy2 = ay2

  local k1x3 = vx3
  local k1y3 = vy3
  local k1vx3 = ax3
  local k1vy3 = ay3

  local tx1 = x1 + 0.5 * dt * k1x1
  local ty1 = y1 + 0.5 * dt * k1y1
  local tvx1 = vx1 + 0.5 * dt * k1vx1
  local tvy1 = vy1 + 0.5 * dt * k1vy1

  local tx2 = x2 + 0.5 * dt * k1x2
  local ty2 = y2 + 0.5 * dt * k1y2
  local tvx2 = vx2 + 0.5 * dt * k1vx2
  local tvy2 = vy2 + 0.5 * dt * k1vy2

  local tx3 = x3 + 0.5 * dt * k1x3
  local ty3 = y3 + 0.5 * dt * k1y3
  local tvx3 = vx3 + 0.5 * dt * k1vx3
  local tvy3 = vy3 + 0.5 * dt * k1vy3

  ax1 = accelx(tx1, ty1, tx2, ty2, m2) + accelx(tx1, ty1, tx3, ty3, m3)
  ay1 = accely(tx1, ty1, tx2, ty2, m2) + accely(tx1, ty1, tx3, ty3, m3)

  ax2 = accelx(tx2, ty2, tx1, ty1, m1) + accelx(tx2, ty2, tx3, ty3, m3)
  ay2 = accely(tx2, ty2, tx1, ty1, m1) + accely(tx2, ty2, tx3, ty3, m3)

  ax3 = accelx(tx3, ty3, tx1, ty1, m1) + accelx(tx3, ty3, tx2, ty2, m2)
  ay3 = accely(tx3, ty3, tx1, ty1, m1) + accely(tx3, ty3, tx2, ty2, m2)

  local k2x1 = tvx1
  local k2y1 = tvy1
  local k2vx1 = ax1
  local k2vy1 = ay1

  local k2x2 = tvx2
  local k2y2 = tvy2
  local k2vx2 = ax2
  local k2vy2 = ay2

  local k2x3 = tvx3
  local k2y3 = tvy3
  local k2vx3 = ax3
  local k2vy3 = ay3

  tx1 = x1 + 0.5 * dt * k2x1
  ty1 = y1 + 0.5 * dt * k2y1
  tvx1 = vx1 + 0.5 * dt * k2vx1
  tvy1 = vy1 + 0.5 * dt * k2vy1

  tx2 = x2 + 0.5 * dt * k2x2
  ty2 = y2 + 0.5 * dt * k2y2
  tvx2 = vx2 + 0.5 * dt * k2vx2
  tvy2 = vy2 + 0.5 * dt * k2vy2

  tx3 = x3 + 0.5 * dt * k2x3
  ty3 = y3 + 0.5 * dt * k2y3
  tvx3 = vx3 + 0.5 * dt * k2vx3
  tvy3 = vy3 + 0.5 * dt * k2vy3

  ax1 = accelx(tx1, ty1, tx2, ty2, m2) + accelx(tx1, ty1, tx3, ty3, m3)
  ay1 = accely(tx1, ty1, tx2, ty2, m2) + accely(tx1, ty1, tx3, ty3, m3)

  ax2 = accelx(tx2, ty2, tx1, ty1, m1) + accelx(tx2, ty2, tx3, ty3, m3)
  ay2 = accely(tx2, ty2, tx1, ty1, m1) + accely(tx2, ty2, tx3, ty3, m3)

  ax3 = accelx(tx3, ty3, tx1, ty1, m1) + accelx(tx3, ty3, tx2, ty2, m2)
  ay3 = accely(tx3, ty3, tx1, ty1, m1) + accely(tx3, ty3, tx2, ty2, m2)

  local k3x1 = tvx1
  local k3y1 = tvy1
  local k3vx1 = ax1
  local k3vy1 = ay1

  local k3x2 = tvx2
  local k3y2 = tvy2
  local k3vx2 = ax2
  local k3vy2 = ay2

  local k3x3 = tvx3
  local k3y3 = tvy3
  local k3vx3 = ax3
  local k3vy3 = ay3

  tx1 = x1 + dt * k3x1
  ty1 = y1 + dt * k3y1
  tvx1 = vx1 + dt * k3vx1
  tvy1 = vy1 + dt * k3vy1

  tx2 = x2 + dt * k3x2
  ty2 = y2 + dt * k3y2
  tvx2 = vx2 + dt * k3vx2
  tvy2 = vy2 + dt * k3vy2

  tx3 = x3 + dt * k3x3
  ty3 = y3 + dt * k3y3
  tvx3 = vx3 + dt * k3vx3
  tvy3 = vy3 + dt * k3vy3

  ax1 = accelx(tx1, ty1, tx2, ty2, m2) + accelx(tx1, ty1, tx3, ty3, m3)
  ay1 = accely(tx1, ty1, tx2, ty2, m2) + accely(tx1, ty1, tx3, ty3, m3)

  ax2 = accelx(tx2, ty2, tx1, ty1, m1) + accelx(tx2, ty2, tx3, ty3, m3)
  ay2 = accely(tx2, ty2, tx1, ty1, m1) + accely(tx2, ty2, tx3, ty3, m3)

  ax3 = accelx(tx3, ty3, tx1, ty1, m1) + accelx(tx3, ty3, tx2, ty2, m2)
  ay3 = accely(tx3, ty3, tx1, ty1, m1) + accely(tx3, ty3, tx2, ty2, m2)

  local k4x1 = tvx1
  local k4y1 = tvy1
  local k4vx1 = ax1
  local k4vy1 = ay1

  local k4x2 = tvx2
  local k4y2 = tvy2
  local k4vx2 = ax2
  local k4vy2 = ay2

  local k4x3 = tvx3
  local k4y3 = tvy3
  local k4vx3 = ax3
  local k4vy3 = ay3

  x1 = x1 + dt * (k1x1 + 2.0 * k2x1 + 2.0 * k3x1 + k4x1) / 6.0
  y1 = y1 + dt * (k1y1 + 2.0 * k2y1 + 2.0 * k3y1 + k4y1) / 6.0
  vx1 = vx1 + dt * (k1vx1 + 2.0 * k2vx1 + 2.0 * k3vx1 + k4vx1) / 6.0
  vy1 = vy1 + dt * (k1vy1 + 2.0 * k2vy1 + 2.0 * k3vy1 + k4vy1) / 6.0

  x2 = x2 + dt * (k1x2 + 2.0 * k2x2 + 2.0 * k3x2 + k4x2) / 6.0
  y2 = y2 + dt * (k1y2 + 2.0 * k2y2 + 2.0 * k3y2 + k4y2) / 6.0
  vx2 = vx2 + dt * (k1vx2 + 2.0 * k2vx2 + 2.0 * k3vx2 + k4vx2) / 6.0
  vy2 = vy2 + dt * (k1vy2 + 2.0 * k2vy2 + 2.0 * k3vy2 + k4vy2) / 6.0

  x3 = x3 + dt * (k1x3 + 2.0 * k2x3 + 2.0 * k3x3 + k4x3) / 6.0
  y3 = y3 + dt * (k1y3 + 2.0 * k2y3 + 2.0 * k3y3 + k4y3) / 6.0
  vx3 = vx3 + dt * (k1vx3 + 2.0 * k2vx3 + 2.0 * k3vx3 + k4vx3) / 6.0
  vy3 = vy3 + dt * (k1vy3 + 2.0 * k2vy3 + 2.0 * k3vy3 + k4vy3) / 6.0

  return x1 + y1 + vx1 + vy1 + x2 + y2 + vx2 + vy2 + x3 + y3 + vx3 + vy3
end

local function benchmark(steps, reps)
  local acc = 0.0
  local r = 0
  while r < reps do
    local x1 = -1.0
    local y1 = 0.0
    local vx1 = 0.0
    local vy1 = -0.25

    local x2 = 1.0
    local y2 = 0.0
    local vx2 = 0.0
    local vy2 = 0.25

    local x3 = 0.0
    local y3 = 0.75
    local vx3 = -0.35
    local vy3 = 0.0

    local i = 0
    while i < steps do
      acc = acc + step(0.01,
                       x1, y1, vx1, vy1,
                       x2, y2, vx2, vy2,
                       x3, y3, vx3, vy3)
      x1 = x1 + 0.000000001 * acc
      i = i + 1
    end
    r = r + 1
  end
  return acc
end

print(benchmark(100, 2700))
