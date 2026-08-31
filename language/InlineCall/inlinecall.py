def add(x, y):
    return x + y

y = 0
for i in range(45000000):
    y = add(i, 1)
print(y)
