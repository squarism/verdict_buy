# goddamn singleton won't work with delayed job, diff VMs

class Counter  
  attr_accessor :number

  def initialize
    @number = 0
  end
  
  def count
    while (@number < 5)
      @number += 1
      puts @number
      sleep 1
    end
  end
  
  def after(job)
    Jobstates.delete_all(:name => "counter")
  end
  
  def display_name
    "Counter Thing"
  end
  
end

#counter = Counter.instance
#counter.count