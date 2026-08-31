var a = "hello"
var b = "world"
var y = ""
for (i in 0...20000000) y = a + b
System.print(y)
