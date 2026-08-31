def f(x, y=1):
    return x + y

z = 0
for i in range(50000000):
    z = f(i)
print(z)
