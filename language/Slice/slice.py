a = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
y = a
for i in range(8000000):
    y = a[1:4]
print(y)
