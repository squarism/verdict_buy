class JobsController < ApplicationController
  
  def index
    @foo = "bar"
  end
  
  def new
    @counter = Counter.instance
    #@counter.delay.count
    @counter = Delayed::Job.enqueue Paranoid.new
  end
  
end
