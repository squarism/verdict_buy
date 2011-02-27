class JobsController < ApplicationController
  
  def index
    @jobs = Delayed::Job.all
    @job_states = Jobstates.all
  end
  
  # this should be create but oh well
  def new
    job_name = params[:id]
    
    
    if Jobstates.find_by_name("counter").nil?
      Jobstates.create(:name => "counter", :started => Date.new, :running => true)
      @counter = Counter.new
      @counter.delay.count
      flash[:notice] = "Created job: #{job_name}"
    else
      flash[:alert] = "Sorry.  Job #{job_name} is already running."
    end
    
    #@counter = Delayed::Job.enqueue Paranoid.new
    redirect_to jobs_path
  end
  
end
