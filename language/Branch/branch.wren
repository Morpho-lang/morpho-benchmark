var k = 0
for (i in 0...35000000) {
  if (i % 2 == 0) {
    k = k + 1
  } else {
    k = k + 2
  }
}
System.print(k)
