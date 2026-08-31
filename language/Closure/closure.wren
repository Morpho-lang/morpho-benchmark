var c = 1
var f = Fn.new { c }

var y = 0
for (i in 0...70000000) y = f.call()
System.print(y)
