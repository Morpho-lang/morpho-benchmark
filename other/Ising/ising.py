# Monte Carlo simulation of the 2D Ising model.

from math import exp
import random as rnd

N = 20
Niter = 10000
T = 2

a = []
for i in range(N):
    row = []
    for j in range(N):
        if rnd.random() < 0.5:
            row.append(-1)
        else:
            row.append(1)
    a.append(row)


def energy(a, i, j):
    il = i - 1
    if il < 0:
        il = N - 1
    ir = i + 1
    if ir > N - 1:
        ir = 0
    jl = j - 1
    if jl < 0:
        jl = N - 1
    jr = j + 1
    if jr > N - 1:
        jr = 0
    return -a[i][j] * (a[il][j] + a[ir][j] + a[i][jl] + a[i][jr])


def magnetization(a):
    m = 0
    for i in range(N):
        for j in range(N):
            m += a[i][j]
    return m / (N * N)


def vis(a):
    for i in range(N):
        line = ""
        for j in range(N):
            if a[i][j] < 0:
                line += "-"
            else:
                line += "X"
        print(line)


vis(a)

print("Run:")

for n in range(Niter):
    for k in range(N * N):
        i = rnd.randrange(N)
        j = rnd.randrange(N)
        old = energy(a, i, j)
        a[i][j] = -a[i][j]
        new = energy(a, i, j)
        if new >= old:
            if exp(-(new - old) / T) < rnd.random():
                a[i][j] = -a[i][j]

vis(a)

print("Magnetization:", magnetization(a))
