// Integrate a 3-body gravitational system with fourth-order Runge-Kutta.

class RK {
  static accelx(x, y, ox, oy, mass) {
    var dx = ox - x
    var dy = oy - y
    var r2 = dx * dx + dy * dy + 0.01
    var invr = 1.0 / r2.sqrt
    var invr3 = invr * invr * invr
    return mass * dx * invr3
  }

  static accely(x, y, ox, oy, mass) {
    var dx = ox - x
    var dy = oy - y
    var r2 = dx * dx + dy * dy + 0.01
    var invr = 1.0 / r2.sqrt
    var invr3 = invr * invr * invr
    return mass * dy * invr3
  }

  static step(dt, x1, y1, vx1, vy1, x2, y2, vx2, vy2, x3, y3, vx3, vy3) {
    var m1 = 1.0
    var m2 = 0.8
    var m3 = 0.6

    var ax1 = RK.accelx(x1, y1, x2, y2, m2) + RK.accelx(x1, y1, x3, y3, m3)
    var ay1 = RK.accely(x1, y1, x2, y2, m2) + RK.accely(x1, y1, x3, y3, m3)

    var ax2 = RK.accelx(x2, y2, x1, y1, m1) + RK.accelx(x2, y2, x3, y3, m3)
    var ay2 = RK.accely(x2, y2, x1, y1, m1) + RK.accely(x2, y2, x3, y3, m3)

    var ax3 = RK.accelx(x3, y3, x1, y1, m1) + RK.accelx(x3, y3, x2, y2, m2)
    var ay3 = RK.accely(x3, y3, x1, y1, m1) + RK.accely(x3, y3, x2, y2, m2)

    var k1x1 = vx1
    var k1y1 = vy1
    var k1vx1 = ax1
    var k1vy1 = ay1

    var k1x2 = vx2
    var k1y2 = vy2
    var k1vx2 = ax2
    var k1vy2 = ay2

    var k1x3 = vx3
    var k1y3 = vy3
    var k1vx3 = ax3
    var k1vy3 = ay3

    var tx1 = x1 + 0.5 * dt * k1x1
    var ty1 = y1 + 0.5 * dt * k1y1
    var tvx1 = vx1 + 0.5 * dt * k1vx1
    var tvy1 = vy1 + 0.5 * dt * k1vy1

    var tx2 = x2 + 0.5 * dt * k1x2
    var ty2 = y2 + 0.5 * dt * k1y2
    var tvx2 = vx2 + 0.5 * dt * k1vx2
    var tvy2 = vy2 + 0.5 * dt * k1vy2

    var tx3 = x3 + 0.5 * dt * k1x3
    var ty3 = y3 + 0.5 * dt * k1y3
    var tvx3 = vx3 + 0.5 * dt * k1vx3
    var tvy3 = vy3 + 0.5 * dt * k1vy3

    ax1 = RK.accelx(tx1, ty1, tx2, ty2, m2) + RK.accelx(tx1, ty1, tx3, ty3, m3)
    ay1 = RK.accely(tx1, ty1, tx2, ty2, m2) + RK.accely(tx1, ty1, tx3, ty3, m3)

    ax2 = RK.accelx(tx2, ty2, tx1, ty1, m1) + RK.accelx(tx2, ty2, tx3, ty3, m3)
    ay2 = RK.accely(tx2, ty2, tx1, ty1, m1) + RK.accely(tx2, ty2, tx3, ty3, m3)

    ax3 = RK.accelx(tx3, ty3, tx1, ty1, m1) + RK.accelx(tx3, ty3, tx2, ty2, m2)
    ay3 = RK.accely(tx3, ty3, tx1, ty1, m1) + RK.accely(tx3, ty3, tx2, ty2, m2)

    var k2x1 = tvx1
    var k2y1 = tvy1
    var k2vx1 = ax1
    var k2vy1 = ay1

    var k2x2 = tvx2
    var k2y2 = tvy2
    var k2vx2 = ax2
    var k2vy2 = ay2

    var k2x3 = tvx3
    var k2y3 = tvy3
    var k2vx3 = ax3
    var k2vy3 = ay3

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

    ax1 = RK.accelx(tx1, ty1, tx2, ty2, m2) + RK.accelx(tx1, ty1, tx3, ty3, m3)
    ay1 = RK.accely(tx1, ty1, tx2, ty2, m2) + RK.accely(tx1, ty1, tx3, ty3, m3)

    ax2 = RK.accelx(tx2, ty2, tx1, ty1, m1) + RK.accelx(tx2, ty2, tx3, ty3, m3)
    ay2 = RK.accely(tx2, ty2, tx1, ty1, m1) + RK.accely(tx2, ty2, tx3, ty3, m3)

    ax3 = RK.accelx(tx3, ty3, tx1, ty1, m1) + RK.accelx(tx3, ty3, tx2, ty2, m2)
    ay3 = RK.accely(tx3, ty3, tx1, ty1, m1) + RK.accely(tx3, ty3, tx2, ty2, m2)

    var k3x1 = tvx1
    var k3y1 = tvy1
    var k3vx1 = ax1
    var k3vy1 = ay1

    var k3x2 = tvx2
    var k3y2 = tvy2
    var k3vx2 = ax2
    var k3vy2 = ay2

    var k3x3 = tvx3
    var k3y3 = tvy3
    var k3vx3 = ax3
    var k3vy3 = ay3

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

    ax1 = RK.accelx(tx1, ty1, tx2, ty2, m2) + RK.accelx(tx1, ty1, tx3, ty3, m3)
    ay1 = RK.accely(tx1, ty1, tx2, ty2, m2) + RK.accely(tx1, ty1, tx3, ty3, m3)

    ax2 = RK.accelx(tx2, ty2, tx1, ty1, m1) + RK.accelx(tx2, ty2, tx3, ty3, m3)
    ay2 = RK.accely(tx2, ty2, tx1, ty1, m1) + RK.accely(tx2, ty2, tx3, ty3, m3)

    ax3 = RK.accelx(tx3, ty3, tx1, ty1, m1) + RK.accelx(tx3, ty3, tx2, ty2, m2)
    ay3 = RK.accely(tx3, ty3, tx1, ty1, m1) + RK.accely(tx3, ty3, tx2, ty2, m2)

    var k4x1 = tvx1
    var k4y1 = tvy1
    var k4vx1 = ax1
    var k4vy1 = ay1

    var k4x2 = tvx2
    var k4y2 = tvy2
    var k4vx2 = ax2
    var k4vy2 = ay2

    var k4x3 = tvx3
    var k4y3 = tvy3
    var k4vx3 = ax3
    var k4vy3 = ay3

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
  }

  static benchmark(steps, reps) {
    var acc = 0.0
    var r = 0
    while (r < reps) {
      var x1 = -1.0
      var y1 = 0.0
      var vx1 = 0.0
      var vy1 = -0.25

      var x2 = 1.0
      var y2 = 0.0
      var vx2 = 0.0
      var vy2 = 0.25

      var x3 = 0.0
      var y3 = 0.75
      var vx3 = -0.35
      var vy3 = 0.0

      var i = 0
      while (i < steps) {
        acc = acc + RK.step(0.01, x1, y1, vx1, vy1, x2, y2, vx2, vy2, x3, y3, vx3, vy3)
        x1 = x1 + 0.000000001 * acc
        i = i + 1
      }
      r = r + 1
    }
    return acc
  }
}

System.print(RK.benchmark(100, 2700))
