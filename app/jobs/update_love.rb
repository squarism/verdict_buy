class UpdateLove
  
  def initialize
  end
  
  def update_love

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
    
    giant_client = GiantLookup.new @api_key

    ArsReview.all.each do |review|
      delay.delayed_search(giant_client, review)
    end    
    
  end
  
  def delayed_search(giant_client, review)
    title = review.ars_title.title

    if giant_client.title_matches? title
      review.love.gb_title = title
    else
      game_names = giant_client.game_names(title)

      # compare using downcase
      if game_names.map{|g| g.downcase}.include?(title.downcase)
        # find a name from giant bomb and use that
        gb_title = game_names.find(title).next
        review.love.gb_title = gb_title
      else
        review.love.gb_title = "inconslusive giant bomb search"
      end
    end
    review.love.save
  end

end