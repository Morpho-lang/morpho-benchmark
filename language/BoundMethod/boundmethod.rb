class Foo
  def initialize(a)
    @a = a
  end

  def report
    @a
  end
end

obj = Foo.new(5)
m = obj.method(:report)
y = 0
60_000_000.times { y = m.call }
puts y
