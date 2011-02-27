# goddamn singleton won't work with delayed job, diff VMs

class Counter  
  attr_accessor :number

  def initialize
    @number = 0
  end
  
  def count
    if Jobstates.find_by_name("counter").nil?
      Jobstates.create(:name => "counter", :started => Date.new, :running => true)
      f = File.open("/tmp/wtf.txt", "w")
      while (@number < 25)
        @number += 1
        puts @number
        sleep 1
      end
    else
      return
    end
  end
  
  def after(job)
    Jobstates.delete_all(:name => "counter")
  end
  
end

#counter = Counter.instance
#counter.count