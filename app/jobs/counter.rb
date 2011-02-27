require 'singleton'
class Counter
  include Singleton
  
  attr_accessor :number

  def initialize
    @number = 0
  end
  
  def count
    f = File.open("/tmp/wtf.txt", "w")
    while (@number < 25)
      @number += 1
      puts @number
      sleep 1
    end
  end
  
end

#counter = Counter.instance
#counter.count