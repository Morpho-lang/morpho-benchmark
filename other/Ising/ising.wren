// Monte Carlo simulation of the 2D Ising model.

import "random" for Random

var N = 20
var Niter = 10000
var T = 2
var rng = Random.new()

var a = []
for (i in 0...N) {
  var row = []
  for (j in 0...N) {
    row.add(rng.float() < 0.5 ? -1 : 1)
  }
  a.add(row)
}

class Ising {
  static energy(a, i, j) {
    var il = i - 1
    if (il < 0) {
      il = N - 1
    }
    var ir = i + 1
    if (ir > N - 1) {
      ir = 0
    }
    var jl = j - 1
    if (jl < 0) {
      jl = N - 1
    }
    var jr = j + 1
    if (jr > N - 1) {
      jr = 0
    }
    return -a[i][j] * (a[il][j] + a[ir][j] + a[i][jl] + a[i][jr])
  }

  static magnetization(a) {
    var m = 0
    for (i in 0...N) {
      for (j in 0...N) {
        m = m + a[i][j]
      }
    }
    return m / (N * N)
  }

  static vis(a) {
    for (i in 0...N) {
      var str = ""
      for (j in 0...N) {
        if (a[i][j] < 0) {
          str = str + "-"
        } else {
          str = str + "X"
        }
      }
      System.print(str)
    }
  }
}

Ising.vis(a)

System.print("Run:")

for (n in 0...Niter) {
  for (k in 0...(N * N)) {
    var i = rng.int(N)
    var j = rng.int(N)
    var old = Ising.energy(a, i, j)
    a[i][j] = -a[i][j]
    var new = Ising.energy(a, i, j)
    if (new >= old) {
      if ((-(new - old) / T).exp < rng.float()) {
        a[i][j] = -a[i][j]
      }
    }
  }
}

Ising.vis(a)

System.print("Magnetization: %(Ising.magnetization(a))")
