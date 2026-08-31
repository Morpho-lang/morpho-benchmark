# Iterate the Mandelbrot map z -> z^2+c until the orbit escapes or hits the iteration limit.


def mandel(cx, cy, maxiter):
    x = 0.0
    y = 0.0
    i = 0
    while i < maxiter:
        xx = x * x
        yy = y * y
        if xx + yy > 4.0:
            return i
        xy = x * y
        y = 2.0 * xy + cy
        x = xx - yy + cx
        i += 1
    return maxiter


def benchmark(width, height, maxiter, reps):
    checksum = 0
    r = 0
    while r < reps:
        j = 0
        while j < height:
            i = 0
            while i < width:
                cx = -2.0 + 3.0 * i / (width - 1)
                cy = -1.25 + 2.5 * j / (height - 1)
                n = mandel(cx, cy, maxiter)
                checksum = checksum + n * (i + 1) + j + r
                i += 1
            j += 1
        r += 1
    return checksum


print(benchmark(160, 120, 64, 80))
