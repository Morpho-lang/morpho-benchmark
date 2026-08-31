def f(*v):
    return len(v)

y = 0
for i in range(14000000):
    y = f(i, 1, 2)
print(y)
