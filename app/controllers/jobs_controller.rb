class JobsController < ApplicationController
  attr_reader :valid_jobs

  def initialize
    @valid_jobs = [ "counter", "paranoid" ]
    super
  end
  
  def index
    @jobs = Delayed::Job.all
    @job_states = Jobstates.all
  end
  
  # this should be create but oh well
  def new
    job_name = params[:id]
    # print ">>>> " + job_name.upcase

    if @valid_jobs.include? job_name    
      if queue_job(job_name)
        flash[:notice] = "Created job: #{job_name}"
      else
        flash[:alert] = "Job #{job_name} is already running."
      end
    else
      flash[:alert] = "Invalid job type."
    end
    
    #@counter = Delayed::Job.enqueue Paranoid.new
    redirect_to jobs_path
  end
  
  def queue_job(job)
    
    case job
    when "counter"
      # goddamn singleton won't work with delayed job, diff ruby VMs
      # we only want one scraper running at a time, lest we get google banned
      if Jobstates.find_by_name("counter").nil?
        Jobstates.create(:name => "counter", :started => Date.new, :running => true)
        @counter = Counter.new
        @counter.delay.count
        return true
      else
        return false
      end
    when "paranoid"
      Delayed::Job.enqueue Paranoid.new
      return true
    else
      puts "You gave me #{job} -- I have no idea what to do with that."
    end
    
    
    
  end
  
end
