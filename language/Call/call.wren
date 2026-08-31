var f = Fn.new { |x| x }

var y = 0
for (i in 0...70000000) y = f.call(i)
System.print(y)
