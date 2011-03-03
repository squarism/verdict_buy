class LovesController < ApplicationController
  
  def index
    @loves = Love.all
  end
  
  # resolve title problems with search
  def find_titles
    respond_to do |format|
      format.json {
        search_term = params[:term]
        puts "JSON: #{search_term}"
        @gb_titles = GiantLookup.new.find_games_by_title(search_term)
        render :text => @gb_titles.to_json
      }
      format.js {
        search_term = params[:term]
        puts "JS #{search_term}"
        @gb_titles = GiantLookup.new.find_games_by_title(search_term)
        render :text => @gb_titles.to_xml
      }
    end
      
  end
    
end
