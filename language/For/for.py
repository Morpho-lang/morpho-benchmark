lst = []
for i in range(20000000):
    lst.append(i)

total = 0
for i in lst:
    total += i
print(total)
