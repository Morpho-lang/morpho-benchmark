# Cast rays at a sphere and shade the intersection.


def shade(px, py):
    ox = 0.0
    oy = 0.0
    oz = -3.0

    dx = px
    dy = py
    dz = 1.0

    cx = 0.0
    cy = 0.0
    cz = 0.0
    r = 1.0

    ocx = ox - cx
    ocy = oy - cy
    ocz = oz - cz

    a = dx * dx + dy * dy + dz * dz
    b = 2.0 * (ocx * dx + ocy * dy + ocz * dz)
    c = ocx * ocx + ocy * ocy + ocz * ocz - r * r

    disc = b * b - 4.0 * a * c

    if disc < 0.0:
        return 0.05

    brightness = disc / (1.0 + disc)

    if brightness > 0.5:
        return brightness
    return 0.25 * brightness


def benchmark(width, height, reps):
    checksum = 0.0
    r = 0
    while r < reps:
        j = 0
        while j < height:
            i = 0
            while i < width:
                px = -1.0 + 2.0 * i / (width - 1)
                py = -0.75 + 1.5 * j / (height - 1)
                s = shade(px, py)
                checksum += s * (1.0 + 0.0001 * i + 0.00001 * j)
                i += 1
            j += 1
        r += 1
    return checksum


print(benchmark(240, 180, 210))
