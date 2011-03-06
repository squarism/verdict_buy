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
  
  # returns hash
  # "date_added"=>"2010-09-30 05:38:46", "first_appearance_concepts"=>[], "name"=>"Herz von Afrika"
  def find(id)
    @client.get_game(id).attributes
  end
  
  def is_title?(title)
    results = @client.find_game(title)
    hits = results.select { |r| r.name.downcase == title.downcase }
    
    hits.size == 1
  end
  
  def find_games_by_title(title)
    results = @client.find_game(title)
    results.map {|r| {:id => r.id, :name=> r.name} }
  end
  
  def find_titles(title)
    results = @client.find_game(title)
    results.collect(&:name)
  end
  
  def update_love
    
    ArsReview.all.each do |review|
      title = review.ars_title
      
      # if a custom title is set, use that instead of the ars title
      if !review.love.title.nil?
        title = review.love.title
      end

      gb_titles = self.find_games_by_title(title)

      # Do we have at least one hit from Giant Bomb?
      if gb_titles.map{|g| g[:name].downcase}.include?(title.downcase)
        # find a title using downcase.  if we have multiple hits, it's probably multiple platforms
        # so just pick the first one
        match = gb_titles.select {|hash| hash[:name].downcase == title.downcase}.first

        review.love.gb_title = match[:name]
        review.love.gb_id = match[:id]
      else
        review.love.gb_title = "<<NO GB HIT>>"
      end
      
      review.love.owned = false
      review.love.ignored = false

      review.love.save
    end
    
  end
  
  def after
    puts "after"
  end
  
end