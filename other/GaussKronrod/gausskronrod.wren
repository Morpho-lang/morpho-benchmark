// Integrate 1/(1+x^2) with the Gauss-Kronrod 7/15 quadrature rule.

class GK {
  static testfun(x) {
    return 1.0 / (1.0 + x * x)
  }

  static gk15pair(center, half, node) {
    var dx = half * node
    return GK.testfun(center - dx) + GK.testfun(center + dx)
  }

  static gk15panel(a, b) {
    var center = 0.5 * (a + b)
    var half = 0.5 * (b - a)

    var fc = GK.testfun(center)
    var ksum = 0.20948214108472783 * fc

    var p = GK.gk15pair(center, half, 0.9914553711208126)
    ksum = ksum + 0.022935322010529225 * p

    p = GK.gk15pair(center, half, 0.9491079123427585)
    ksum = ksum + 0.06309209262997855 * p

    p = GK.gk15pair(center, half, 0.8648644233597691)
    ksum = ksum + 0.10479001032225018 * p

    p = GK.gk15pair(center, half, 0.7415311855993945)
    ksum = ksum + 0.14065325971552592 * p

    p = GK.gk15pair(center, half, 0.5860872354676911)
    ksum = ksum + 0.1690047266392679 * p

    p = GK.gk15pair(center, half, 0.4058451513773972)
    ksum = ksum + 0.1903505780647854 * p

    p = GK.gk15pair(center, half, 0.20778495500789847)
    ksum = ksum + 0.20443294007529889 * p

    return half * ksum
  }

  static integrate(a, b, panels) {
    var total = 0.0
    var h = (b - a) / panels
    var i = 0
    while (i < panels) {
      var x0 = a + i * h
      var x1 = x0 + h
      total = total + GK.gk15panel(x0, x1)
      i = i + 1
    }
    return total
  }

  static benchmark(reps, panels) {
    var acc = 0.0
    var r = 0
    var eps = 1e-12
    while (r < reps) {
      acc = acc + GK.integrate(-1.0 - eps, 1.0 + eps, panels)
      if (acc < 0.0) {
        acc = -acc
      }
      r = r + 1
    }
    return acc
  }
}

System.print(GK.integrate(-1.0, 1.0, 64))
System.print(GK.benchmark(33000, 64))
