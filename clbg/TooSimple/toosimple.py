# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/

import sys 
def main():
    # mtime side-effect
    with open( './one', 'w') as f: pass

    n = int(sys.argv[1])
    sum = 0.0
    flip = -1.0
    for i in range(1,n):    
        flip *= -1.0        
        sum += flip / (2*i - 1)                                      
    print("%.9f" % (sum*4.0))
    
    # mtime side-effect
    with open( './two', 'w') as f: pass
  
main() 
