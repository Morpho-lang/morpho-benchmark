var N = 8000000
var a = [1, 2, 3]
var k = 0

for (i in 0...N) {
  var b = a[0]
  var c = a[1]
  var d = a[2]
  var e = a[0]
  var f = a[1]
  var g = a[2]
  k = k + 1
}

System.print(k)
