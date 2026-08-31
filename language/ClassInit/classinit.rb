class Foo
  attr_reader :x
  def initialize
    @x = 1
  end
end

o = Foo.new
15_000_000.times { o = Foo.new }
puts o.x
