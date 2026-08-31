-- Integrate 1/(1+x^2) with the Gauss-Kronrod 7/15 quadrature rule.

local function testfun(x)
  return 1.0 / (1.0 + x * x)
end

local function gk15pair(center, half, node)
  local dx = half * node
  return testfun(center - dx) + testfun(center + dx)
end

local function gk15panel(a, b)
  local center = 0.5 * (a + b)
  local half = 0.5 * (b - a)

  local fc = testfun(center)
  local ksum = 0.20948214108472783 * fc

  local p = gk15pair(center, half, 0.9914553711208126)
  ksum = ksum + 0.022935322010529225 * p

  p = gk15pair(center, half, 0.9491079123427585)
  ksum = ksum + 0.06309209262997855 * p

  p = gk15pair(center, half, 0.8648644233597691)
  ksum = ksum + 0.10479001032225018 * p

  p = gk15pair(center, half, 0.7415311855993945)
  ksum = ksum + 0.14065325971552592 * p

  p = gk15pair(center, half, 0.5860872354676911)
  ksum = ksum + 0.1690047266392679 * p

  p = gk15pair(center, half, 0.4058451513773972)
  ksum = ksum + 0.1903505780647854 * p

  p = gk15pair(center, half, 0.20778495500789847)
  ksum = ksum + 0.20443294007529889 * p

  return half * ksum
end

local function integrate(a, b, panels)
  local total = 0.0
  local h = (b - a) / panels
  local i = 0
  while i < panels do
    local x0 = a + i * h
    local x1 = x0 + h
    total = total + gk15panel(x0, x1)
    i = i + 1
  end
  return total
end

local function benchmark(reps, panels)
  local acc = 0.0
  local r = 0
  local eps = 1e-12
  while r < reps do
    acc = acc + integrate(-1.0 - eps, 1.0 + eps, panels)
    if acc < 0.0 then
      acc = -acc
    end
    r = r + 1
  end
  return acc
end

print(integrate(-1.0, 1.0, 64))
print(benchmark(33000, 64))
