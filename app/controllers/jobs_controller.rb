class JobsController < ApplicationController
  attr_reader :valid_jobs

  def initialize
    @valid_jobs = [ "counter", "paranoid", "scraper", "artwork", "artwork_single" ]
    super
  end
  
  def index
    @jobs = Delayed::Job.all
    @job_states = Jobstates.all
  end
  
  # this should be create but oh well
  def new
    job_name = params[:id]

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
    when "scraper"
      if Jobstates.find_by_name("scraper").nil?
        Jobstates.create(:name => "scraper", :started => Date.new, :running => true)
        s = Scraper.new
        s.delay.scrape
        return true
      else
        return false
      end
    else
      puts "You gave me #{job} -- I have no idea what to do with that."
    end
  end
  
  def destroy
    job = params[:id]
    begin
      Delayed::Job.destroy job
    rescue ActiveRecord::RecordNotFound
      # we hit this when you try to clear a job that's already gone.
      # TODO: something better here.
      puts "meh."
    end
    redirect_to jobs_path
  end
  
end
