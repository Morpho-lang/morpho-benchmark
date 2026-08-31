-- Monte Carlo simulation of the 2D Ising model.

local N = 20
local Niter = 10000
local T = 2

math.randomseed(os.time())

local a = {}
for i = 0, N - 1 do
  a[i] = {}
  for j = 0, N - 1 do
    if math.random() < 0.5 then
      a[i][j] = -1
    else
      a[i][j] = 1
    end
  end
end

local function energy(a, i, j)
  local il = i - 1
  if il < 0 then il = N - 1 end
  local ir = i + 1
  if ir > N - 1 then ir = 0 end
  local jl = j - 1
  if jl < 0 then jl = N - 1 end
  local jr = j + 1
  if jr > N - 1 then jr = 0 end
  return -a[i][j] * (a[il][j] + a[ir][j] + a[i][jl] + a[i][jr])
end

local function magnetization(a)
  local m = 0
  for i = 0, N - 1 do
    for j = 0, N - 1 do
      m = m + a[i][j]
    end
  end
  return m / (N * N)
end

local function vis(a)
  for i = 0, N - 1 do
    local str = ""
    for j = 0, N - 1 do
      if a[i][j] < 0 then
        str = str .. "-"
      else
        str = str .. "X"
      end
    end
    print(str)
  end
end

vis(a)

print("Run:")

for n = 1, Niter do
  for k = 1, N * N do
    local i = math.random(0, N - 1)
    local j = math.random(0, N - 1)
    local old = energy(a, i, j)
    a[i][j] = -a[i][j]
    local new = energy(a, i, j)
    if new >= old then
      if math.exp(-(new - old) / T) < math.random() then
        a[i][j] = -a[i][j]
      end
    end
  end
end

vis(a)

print("Magnetization: " .. magnetization(a))
