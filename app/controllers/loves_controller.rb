class LovesController < ApplicationController
  
  def index
    @loves = Love.all
  end
  
end
