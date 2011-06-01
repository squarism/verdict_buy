class LovesController < ApplicationController
  
  def index
    @loves = Love.where(:ignored => false).includes(:ars_titles)
    @heading = "Verdict: Buy"
  end
  
  def owned
    @loves = Love.where(:owned => true)
    @heading = "Titles Owned"
    render :index
  end
  
  def buy
    @loves = Love.where(:owned => false, :ignored => false)
    @heading = "Buy List"
    render :index
  end
  
  # resolve title problems with search
  def find_titles
    respond_to do |format|
      format.json {
        search_term = params[:term]
        puts "JSON: #{search_term}"
        
        # looks like this
        # [{:id=>11439, :name=>"Herzog Zwei"}, {:id=>5048, :name=>"Herzog"}, {:id=>32818, :name=>"Herz von Afrika"}]
        @gb_titles = GiantLookup.new.find_games_by_title(search_term)

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
        
        # don't do anything if autocomplete is submitting blanks
        if !name.blank? && !giant_bomb_id.blank? && !love_id.blank?        
          @game = Love.find(love_id)
          @game.title = name
          @game.gb_id = giant_bomb_id
          @game.save

          # schedule update of that dude.
          ArtworkWorker.new.delay.update(@game.gb_id)
        
          # render nothin and snack on a muffin.
          render :text => "Updated game information in table.  Thanks."
        else
          render :text => "Not enough parameters from the ajax call.  You're probably autocompleting too fast."
        end
      }
    end
  end
  
  # TODO: refactor this for DRY
  def update_owned
    respond_to do |format|
      format.json {        
        love_id = params["id"]
        value = params["value"]
        
        # don't do anything if submitted blanks
        if !value.nil? && !love_id.blank?        
          @game = Love.find(love_id)
          @game.owned = value
          @game.save

          # render nothin and snack on a muffin.
          render :text => "Updated owned on #{@game.gb_title}.  Thanks."
        else
          render :text => "Not enough parameters from the ajax call.  I don't know what you did with the checkboxes."
        end
      }
    end
  end
  
  def update_ignored
    respond_to do |format|
      format.json {
        love_id = params["id"]
        value = params["value"]
        
        # don't do anything if submitted blanks
        if !value.nil? && !love_id.blank?        
          @game = Love.find(love_id)
          @game.ignored = value
          @game.save

          # render nothin and snack on a muffin.
          render :text => "Updated ignored on #{@game.gb_title}.  Thanks."
        else
          render :text => "Not enough parameters from the ajax call.  I don't know what you did with the checkboxes."
        end
      }
    end
  end
  
  def show
    id = params[:id]
    @love = Love.find id
    
    # if the title is dirty and hasn't been overridden, display set me, otherwise use the custom title
    if @love.gb_title == "<<NO GB HIT>>"
      if @love.title
        @default = @love.title
      else
        @default = "Set me"
      end
    else
      @default = @love.gb_title
    end
    
  end
  
  def update
    flash[:alert] = "There's no title named that in Giant Bomb's DB."
    redirect_to love_path
    #render :text => "You are overriding a title that doesn't exist dude."
  end
    
end
