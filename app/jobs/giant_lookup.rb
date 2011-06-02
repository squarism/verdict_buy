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
  
  # see if a string is an exact name anywhere in giant bomb
  def is_title?(title)
    results = @client.find_game(title)
    title_names = results.collect{|game| game.name}
    title_names.uniq!
    title_names_downcase = title_names.map {|game| game.downcase}
    title_names_downcase.include? title.downcase
  end
  
  def find_games_by_title(title)
    title.encode("UTF-8", :invalid => :replace, :undef =>:replace, :replace => "?")
    results = @client.find_game(title)
    
    # if we got a hit, return an array of game objects
    if !results.empty?
      gb_objects = Array.new
      results.each do |r|
        gb_objects << self.find(r.attributes["id"])
      end
      return gb_objects
    else
      return nil
    end
  end
  
  def find_titles(title)
    results = @client.find_game(title)
    return results.collect(&:name) unless results.nil?
    
    # try with no parens: Blue Dragon (Xbox 360)
    title_without_parens = title.scan(/(.*)(\(.*\))/).flatten.first.strip
    results = @client.find_game(title_without_parens)
    return results.collect(&:name) unless results.nil?
    
    # try with no commas: Blue Dragon (Xbox 360),
    results = @client.find_game(title_without_parens.gsub(",", ""))
    return results.collect(&:name) unless results.nil?
    
    #results.collect(&:name)
  end
  
  def update_love
    
    ArsReview.with_invalid_titles.each do |review|
    # ArsReview.all.each do |review|
      title = review.ars_title
      
      # utf-8 problem fix
      title.encode("UTF-8", :invalid => :replace, :undef =>:replace, :replace => "?")
      puts "TITLE: #{title}"
      
      # if a custom title is set, use that instead of the ars title
      if !review.love.title.nil?
        title = review.love.title
      end
      
      # check for exact matches first
      exact_match = try_exact_match review
      if exact_match
        set_love(review, exact_match)
      else
        match = handle_fifty_fifty review
        puts "MATCH:#{match}"
        if match
          set_love(review, match)
        else
          puts "else"
          review.love.gb_title = "<<NO GB HIT>>"
          review.love.ignored = 0
          review.love.save
        end
      end
      # only set to defaults if is null in DB, otherwise, it will overwrite own/ignore each run
    end
    
  end
  
  # return a GBID from an array of titles.  any we have an exact title?
  def try_exact_match(review)
    possible_titles = review.ars_titles.collect(&:title)
    exact_match = false
    possible_titles.each do |possible_title|
      puts "TRYING #{possible_title} for exact match"
      
      # TODO: self here instead of class?
      if GiantLookup.new.is_title? possible_title
        return GiantLookup.new.find_games_by_title(possible_title).first
      end
    end
    
    # nothing found, oh well
    return nil
  end
  
  # our percentage guess might be 50/50, so we check each one for an exact hit
  def handle_fifty_fifty(review)
    title = review.ars_title
    gb_titles = self.find_games_by_title(title)
    
    puts "GB_TITLES: #{gb_titles.collect(&:name)}"
    if gb_titles.nil?
      return nil
    end
    
    if gb_titles.size > 2
      raise ArgumentError
    end
    
    if gb_titles
      # Do we have at least one hit from Giant Bomb?
      if gb_titles.map{|g| g["name"].downcase}.include?(title.downcase)
        # find a title using downcase.  if we have multiple hits, it's probably multiple platforms
        # so just pick the first one
        match = gb_titles.select {|hash| hash["name"].downcase == title.downcase}.first
      end
    end
  end
  
  # update our love cache table
  def set_love(review, gb_object)
    # we should have only one title from exact_match at this point
    id = gb_object["id"]
    review.love.gb_title = gb_object["name"]
    review.love.gb_id = gb_object["id"]

    # cache attributes from giant_bomb, avoids web call on game detail view
    review.love.platforms = gb_object["platforms"].collect{|h| h["name"]}.join(", ")
    if !gb_object["original_release_date"].nil?
      review.love.release_date = Date.parse(gb_object["original_release_date"]).strftime("%a, %d-%b-%Y")
    end
    review.love.developers = gb_object["developers"].collect{|h| h["name"]}.join(", ")
    review.love.publishers = gb_object["publishers"].collect{|h| h["name"]}.join(", ")
    review.love.game_rating = gb_object["original_game_rating"]
    review.love.description = gb_object["deck"]
    
    review.love.owned = false if review.love.owned.nil?
    review.love.ignored = false if review.love.ignored.nil?
    review.love.save
  end
  
  def after
    puts "after giant_lookup job"
  end
  
end