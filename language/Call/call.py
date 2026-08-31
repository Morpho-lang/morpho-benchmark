def f(x):
    return x

y = 0
for i in range(70000000):
    y = f(i)
print(y)
