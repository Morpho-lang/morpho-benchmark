# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# contributed by Isaac Gouy

class Tree
  attr_accessor :left, :right

  def initialize(left, right)
    @left = left
    @right = right 
  end     
  
  def self.with depth
    depth == 0 \
      ? self.new(nil, nil) \
      : self.new( Tree.with(depth-1), Tree.with(depth-1) ) 
  end    
  
  def node_count
    @left == nil \
      ? 1 \
      : 1 + @left.node_count + @right.node_count
  end     
  
  def clear
    if @left != nil
      @left.clear
      @left = nil
      @right.clear      
      @right = nil         
    end  
  end   
end

def stretch(depth)           
  puts "stretch tree of depth #{depth}\t check: #{count(depth)}"   
end

def count(depth)
  t = Tree.with(depth)        
  c = t.node_count()
  t.clear() 
  return c
end

def main n
  min_depth = 4  
  max_depth = min_depth + 2 > n ? min_depth + 2 : n
  stretch_depth = max_depth + 1  
  
  stretch(stretch_depth)  
  long_lived_tree = Tree.with max_depth   
  
  for depth in (min_depth .. max_depth).step(2)
    iterations = 1 << (max_depth - depth + min_depth)  
    sum = 0      
    for i in 1 .. iterations 
      sum += count(depth)
    end      
    puts "#{iterations}\t trees of depth #{depth}\t check: #{sum}"     
  end
  c = long_lived_tree.node_count  
  long_lived_tree.clear()  
  puts "long lived tree of depth #{max_depth}\t check: #{c}"  
end 

n = ARGV.empty? ? 10 : ARGV[0].to_i
main n

