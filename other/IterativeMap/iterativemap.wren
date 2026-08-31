// Iterate the Mandelbrot map z -> z^2+c until the orbit escapes or hits the iteration limit.

class Iter {
  static mandel(cx, cy, maxiter) {
    var x = 0.0
    var y = 0.0
    var i = 0
    while (i < maxiter) {
      var xx = x * x
      var yy = y * y
      if (xx + yy > 4.0) {
        return i
      }
      var xy = x * y
      y = 2.0 * xy + cy
      x = xx - yy + cx
      i = i + 1
    }
    return maxiter
  }

  static benchmark(width, height, maxiter, reps) {
    var checksum = 0
    var r = 0
    while (r < reps) {
      var j = 0
      while (j < height) {
        var i = 0
        while (i < width) {
          var cx = -2.0 + 3.0 * i / (width - 1)
          var cy = -1.25 + 2.5 * j / (height - 1)
          var n = Iter.mandel(cx, cy, maxiter)
          checksum = checksum + n * (i + 1) + j + r
          i = i + 1
        }
        j = j + 1
      }
      r = r + 1
    }
    return checksum
  }
}

System.print(Iter.benchmark(160, 120, 64, 80))
