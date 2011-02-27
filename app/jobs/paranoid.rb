class Paranoid
  
  def initialize
    @number = 0
  end
  
  def enqueue(job)
    puts 'paranoid_job/enqueue'
  end

  def perform
    f = File.open("/tmp/wtf.txt", "w")
    f.sync = true
    while (@number < 5)
      @number += 1
      f.puts @number
      sleep 0.5
    end
    # exception test
    raise Exception, "Invalid Facey-Face."
    f.close
  end

  def before(job)
    puts 'paranoid_job/start'
  end

  def after(job)
    puts 'paranoid_job/after'
  end

  def success(job)
    puts 'paranoid_job/success'
  end

  def error(job, exception)
    puts "notify_hoptoad(exception)"
  end

  def failure
    puts "page_sysadmin_in_the_middle_of_the_night"
  end
end
