var N = 10000000
var d = { "a": 1, "b": 2, "c": 3 }
var k = 0

for (i in 0...N) {
  var b = d["a"]
  var c = d["b"]
  var e = d["c"]
  var f = d["a"]
  var g = d["b"]
  var h = d["c"]
  k = k + 1
}

System.print(k)
