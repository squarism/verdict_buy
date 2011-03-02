require 'giant_bomb'
require 'yaml'

class GiantLookup
  attr_accessor :client
  attr_accessor :api_key
  
  def initialize
    begin
      api_key_config = File.open(Rails.root.to_path + "/config/api_key.yml")
    rescue Errno::ENOENT
      puts "Please copy api_key.example.yml to api_key.yml and change your key."
      puts "If you don't have a key, sign up at api.giantbomb.com."
      return
    end
    
    config_hash = YAML::load(api_key_config)
    if config_hash[:api_key].nil?
      puts "File api_key.yml has no api_key in it.  :("
      exit 1
    end

    @api_key = config_hash[:api_key]
    
    @client = GiantBomb::Search.new(@api_key)
  end
  
  def title_matches?(title)
    results = @client.find_game(title)
    results.size
    
    if results.size == 1
      return true
    else
      puts "Giant Lookup Match Miss: #{title} with #{results.size} hits."
      return false
    end
    
  end
  
  def is_title?(title)
    results = @client.find_game(title)
    hits = results.select { |r| r.name.downcase == title.downcase }
    
    hits.size == 1
  end
  
  def game_names(title)
    results = @client.find_game(title)
    results.collect(&:name)
  end
  
  def update_love_giant_titles
    
    ArsReview.all.each do |review|
      title = review.ars_title

      if self.title_matches? title
        review.love.gb_title = title
      else
        names = self.game_names(title)

        # compare using downcase
        if names.map{|g| g.downcase}.include?(title.downcase)
          # find a name from giant bomb and use that
          gb_title = names.find(title).next
          review.love.gb_title = gb_title
        else
          review.love.gb_title = "<<NO GB HIT>>"
        end
      end
      review.love.save
    end
  end
  
end