class Foo:
    def __init__(self, a):
        self.a = a

obj = Foo(5)
y = 0
for i in range(70000000):
    y = obj.a
print(y)
