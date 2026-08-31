# Integrate 1/(1+x^2) with the Gauss-Kronrod 7/15 quadrature rule.

def testfun(x):
    return 1.0 / (1.0 + x * x)


def gk15pair(center, half, node):
    dx = half * node
    return testfun(center - dx) + testfun(center + dx)


def gk15panel(a, b):
    center = 0.5 * (a + b)
    half = 0.5 * (b - a)

    fc = testfun(center)
    ksum = 0.20948214108472783 * fc

    p = gk15pair(center, half, 0.9914553711208126)
    ksum += 0.022935322010529225 * p

    p = gk15pair(center, half, 0.9491079123427585)
    ksum += 0.06309209262997855 * p

    p = gk15pair(center, half, 0.8648644233597691)
    ksum += 0.10479001032225018 * p

    p = gk15pair(center, half, 0.7415311855993945)
    ksum += 0.14065325971552592 * p

    p = gk15pair(center, half, 0.5860872354676911)
    ksum += 0.1690047266392679 * p

    p = gk15pair(center, half, 0.4058451513773972)
    ksum += 0.1903505780647854 * p

    p = gk15pair(center, half, 0.20778495500789847)
    ksum += 0.20443294007529889 * p

    return half * ksum


def integrate(a, b, panels):
    total = 0.0
    h = (b - a) / panels
    i = 0
    while i < panels:
        x0 = a + i * h
        x1 = x0 + h
        total += gk15panel(x0, x1)
        i += 1
    return total


def benchmark(reps, panels):
    acc = 0.0
    r = 0
    eps = 1e-12
    while r < reps:
        acc += integrate(-1.0 - eps, 1.0 + eps, panels)
        if acc < 0.0:
            acc = -acc
        r += 1
    return acc


print(integrate(-1.0, 1.0, 64))
print(benchmark(33000, 64))
