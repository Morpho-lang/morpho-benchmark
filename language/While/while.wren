var y = 1
var i = 0
while (i < 50000000) {
  y = 1.00001 * y
  i = i + 1
}
System.print(y)
