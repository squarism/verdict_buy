class LovesController < ApplicationController
  
  def index
    @loves = Love.all
  end
  
  # resolve title problems with search
  def find_titles(title)
    @gb_titles = GiantLookup.new.find_games_by_title("Hard Corps.")
  end
  
end
