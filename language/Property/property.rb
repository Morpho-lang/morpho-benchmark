class Foo
  attr_reader :a
  def initialize(a)
    @a = a
  end
end

obj = Foo.new(5)
y = 0
70_000_000.times { y = obj.a }
puts y
