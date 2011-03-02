require 'giant_bomb'
require 'yaml'

class GiantLookup
  attr_accessor :client
  attr_accessor :api_key
  
  def initialize(api_key)
    @api_key = api_key
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
  
end