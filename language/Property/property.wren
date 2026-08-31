class Foo {
  construct new(a) { _a = a }
  a { _a }
}

var obj = Foo.new(5)
var y = 0
for (i in 0...70000000) y = obj.a
System.print(y)
