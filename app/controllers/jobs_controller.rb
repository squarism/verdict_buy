class JobsController < ApplicationController
  
  def index
    @foo = "bar"
  end
  
  def new
    @counter = Counter.new
    @counter.delay.count
    #@counter = Delayed::Job.enqueue Paranoid.new
  end
  
end
