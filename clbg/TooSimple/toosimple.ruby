# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/

# mtime side-effect
open("./one", "w").close()

n = ARGV[0].to_i
sum = 0.0
flip = -1.0
for i in 1..n do
    flip *= -1.0        
    sum += flip / (2*i - 1) 
end
puts "%0.9f" % (sum*4.0)

# mtime side-effect
open("./two", "w").close()
