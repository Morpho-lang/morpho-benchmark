var add = Fn.new { |x, y| x + y }

var y = 0
for (i in 0...45000000) y = add.call(i, 1)
System.print(y)
