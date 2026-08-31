c = 1
f = -> { c }

y = 0
70_000_000.times { y = f.call }
puts y
