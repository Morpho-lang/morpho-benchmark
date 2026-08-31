class Foo:
    def __init__(self):
        self.x = 1

o = Foo()
for i in range(15000000):
    o = Foo()
print(o.x)
