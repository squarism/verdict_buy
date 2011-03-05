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
        @gb_titles = GiantLookup.new.find_games_by_title(search_term) #.collect{|h| h[:name]}
        #@gb_titles = [{:id=>11439, :name=>"Herzog Zwei"}, {:id=>5048, :name=>"Herzog"}, {:id=>32818, :name=>"Herz von Afrika"}]
        render :json => @gb_titles.to_json
      }
      
      format.js {
        search_term = params[:term]
        puts "JS #{search_term}"
        @gb_titles = GiantLookup.new.find_games_by_title(search_term)
        #render :text => @gb_titles.to_xml
      }
    end
      
  end
  
  def revise_title
    respond_to do |format|
      format.json {
        # So here our textbox has been filled out with a better title
        # than what we detected from ars.  So we want to save this title
        # to a title column in the <3 love <3 table.  Later we'll use that column
        # instead of all the automagic stuff.
        puts params[:page]
        name = params[:page]["name"]
        giant_bomb_id = params[:page]["gbid"]
        love_id = params[:page]["id"]
        
        @game = Love.find(love_id)
        @game.gb_title = name
        @game.gb_id = giant_bomb_id
        @game.save

        # render nothin and snack on a muffin.
        render :text => "Updated game information in table.  Thanks."
      }
    end
  end
  
  def show
    # @love = Love.where(:gb_id => params[:id]).first
    id = params[:id]
    @love = Love.find id
    
    if !@love.gb_id.nil?
      @gb_object = GiantLookup.new.find @love.gb_id
    end
  end
    
end
