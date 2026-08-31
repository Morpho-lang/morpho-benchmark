N = 17_000_000

def sphere(x, y, z)
  x**2 + y**2 + z**2
end

N.times { sphere(0.1, 0.2, 0.3) }
