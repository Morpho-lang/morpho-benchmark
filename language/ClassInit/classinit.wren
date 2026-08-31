class Foo {
  construct new() { _x = 1 }
  x { _x }
}

var o = Foo.new()
for (i in 0...15000000) o = Foo.new()
System.print(o.x)
