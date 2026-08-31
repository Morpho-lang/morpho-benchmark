N = 10000000
d = {"a": 1, "b": 2, "c": 3}
k = 0

for i in range(N):
    b = d["a"]
    c = d["b"]
    e = d["c"]
    f = d["a"]
    g = d["b"]
    h = d["c"]
    k += 1

print(k)
