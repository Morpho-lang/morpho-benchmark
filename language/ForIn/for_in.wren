var N = 3000000
var M = 10

var sqr = Fn.new { |x| x * x }

for (k in 1..N) {
  for (i in 1..M) {
    sqr.call(0.1)
  }
}
