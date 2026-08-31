c = 1

def f():
    return c

y = 0
for i in range(70000000):
    y = f()
print(y)
