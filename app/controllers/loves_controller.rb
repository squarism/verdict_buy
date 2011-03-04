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
        # @gb_titles = [{:game_id=>7812, :name=>"Shenmue"}, {:game_id=>1187, :name=>"Shenmue II"}, {:game_id=>116, :name=>"Shengnu zhi Ge: Heroine Anthem II - The Angel of Sarem"}, {:game_id=>258, :name=>"Shengnu zhi Ge: Heroine Anthem - The Elect of Wassernixe"}, {:game_id=>20407, :name=>"Fengse Huanxiang 4: Shengzhan de Zhongyan"}, {:game_id=>17794, :name=>"Junyong Shenqing"}, {:game_id=>5567, :name=>"Shengnu zhi Ge - Heroine Anthem XP"}, {:game_id=>29114, :name=>"Shenmue Online"}]
        render :json => @gb_titles.to_json

        # render :json => {
        #   :query => 'e',
        #   :suggestions => @gb_titles.collect{|h| h[:name]},
        #   :data => @gb_titles.collect{|h| h[:id]}
        # }
                
        # array = Array.new
        # @gb_titles.each do |h|
        #   array << [ h[:name], h[:game_id] ].join("|")
        # end
        # array
        # render :text => array
      }
      
      format.js {
        search_term = params[:term]
        puts "JS #{search_term}"
        @gb_titles = GiantLookup.new.find_games_by_title(search_term)
        #render :text => @gb_titles.to_xml
      }
    end
      
  end
    
end
