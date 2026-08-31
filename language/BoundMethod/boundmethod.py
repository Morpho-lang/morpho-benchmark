class Foo:
    def __init__(self, a):
        self.a = a

    def report(self):
        return self.a

obj = Foo(5)
m = obj.report
y = 0
for i in range(60000000):
    y = m()
print(y)
