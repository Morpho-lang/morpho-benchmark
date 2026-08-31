k = 0
for i in range(30000000):
    try:
        k = k + 1
    except Exception:
        k = k
print(k)
