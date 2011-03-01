# arstechnica game recommendation finder and syncer

require 'typhoeus'
require 'nokogiri'
require 'json'
require 'open-uri'
require 'uri'
require 'date'
require 'yaml'
require 'base64'

class Scraper
  attr_accessor :number_of_results
  attr_accessor :reviews        # hash of parsed reviews
  attr_accessor :starting_url   # static google results URL
  attr_accessor :page           # google result page iterator number
  attr_accessor :page_size      # number of results on page
  attr_accessor :test_mode      # uses cache .yml file for testing instead of hitting google
  attr_accessor :limit
  attr_accessor :limit_count
  attr_accessor :parsed_reviews
  
  def initialize
    self.number_of_results = 0
    self.page = 0
    @page_size = 10
    self.reviews = Array.new
    self.parsed_reviews = Array.new

    # the below is for test/dev
    self.test_mode = false     # read from dump file instead of going to internet?
    self.limit = 1            # pages of google results to process
    self.limit_count = 0      # current page of google result
    
    if !self.test_mode
      begin
        puts "Cleared cache file."
        File.delete(File.dirname(__FILE__) + "/ars_dump.yml")
      rescue Errno::ENOENT
        puts "Cache file already gone."
      end
    end

    # this is just concat'd so the code doesn't go off the page to the right.    
    # google search results minus the forums and news summary pages which would cause duplicates
    @starting_url = "http://www.google.com/search?q=site:arstechnica.com+%22verdict:+buy%22"
    @starting_url << "&num=#{@page_size}&hl=en&safe=off&filter=0&start="
  end
  
  def split_results_page(doc)
    doc.css('li.g')
  end
  
  def map_search_chunk(result_html)
    # find title
    @title = result_html.css('h3.r a.l').text 
    # find link
    @link = result_html.css('h3.r a.l').attr('href').text
    # find date timestamp of when article was posted according to google
    @date_str = result_html.css('div.s').text[0..12]

    # remove all periods from date string
    @date_str.gsub!(/\./, '')
    begin
      @date = Date.parse(@date_str)
    rescue ArgumentError
      @date = "INVALID on #{@link}"
      puts $!
    end
    
    {:title => @title, :link => @link, :date => @date}
  end
  
  def get_article(url)
    @nokogiri_doc = Nokogiri::HTML(open(url))

    # base64 the doc
    @encoded_doc = Base64::encode64(@nokogiri_doc.to_s)
    { :title => @title, :link => @link, :date => @date, :doc => @encoded_doc }
  end
  
  # dump a yml file for testing parsing
  def dump_file(array)
    # flush to YAML file
    File.open(File.dirname(__FILE__) + "/ars_dump.yml", "a") do |file|
      puts "review_buffer: #{array.size} || reviews: #{self.reviews.size} || page_count: #{self.limit_count}"
      array.each do |review|
        file.puts YAML::dump(review)
      end
    end
  end
  
  def load_reviews_from_cache_file
    # Skip hammering google by loading from a cache file
    dump_file = File.open(File.dirname(__FILE__) + "/ars_dump.yml")

    YAML::load_documents(dump_file) do |doc|
      self.reviews << doc
    end

    dump_file.close
  end
  
  def write_reviews_to_db(array)
    # temp for testing
    ArsReview.delete_all
    Love.delete_all
    ArsTitle.delete_all
    
    array.each do |a|
      # link is primary key so don't create articles twice
      if ArsReview.where(:link => a[:link]).empty?
        review = ArsReview.new(
          :article_title => a[:title],
          :link => a[:link],
          :date => a[:date]
        )
        
        love = Love.new #(:ars_title => review.article_title)
        review.love = love
        
        # number of times a title appears from an ars article using a variety of guessing methods
        title_percentage = ArsReducer.new.reduce a
        
        title_array = Array.new
        title_percentage.each do |key, value|
          title_array << ArsTitle.new(:title => key, :percent_appears => value)
        end
        
        review.ars_titles = title_array
        review.save!          
      end
    end
  end

  def scrape(args={})
    if !args[:test_mode].nil?
      @test_mode = args[:test_mode]
    end
    
    # test mode speeds up development because you don't have to wait 5 minutes to scrape ars
    if self.test_mode
      load_reviews_from_cache_file
    else
      # get the google results for the current page
      google_page_of_results = Nokogiri::HTML(open(self.search_url))

      review_buffer = Array.new

      # parse the result
      google_results = split_results_page(google_page_of_results)
      google_results.each do |result|
        mapped_result = map_search_chunk(result)
        puts mapped_result[:link]
        article_hash = get_article(mapped_result[:link])
        self.reviews << article_hash
        review_buffer << article_hash
      end

      # if we run out of google results size will be less than 10 (full page of links)
      if google_page_of_results.css('li.g').size >= 10
        self.page += 1
        puts "===> Sleeping before page: #{self.page}.  ZZzzz..."
        dump_file(review_buffer) unless @test_mode
        sleep 3 # sleep to avoid hammering google and getting banned
        # set limit to -1 to scrape all google results, all pages
        if self.limit == -1 || self.limit_count < self.limit - 1
          self.limit_count += 1
          scrape
        end
      end

      # will get a 503 if you hammer google, so we'll cache to file
      # this won't fire because of the return near top
      if !@test_mode
        File.open(File.dirname(__FILE__) + "/ars_dump.yml", "a") do |file|
          review_buffer.each do |review|
            file.puts YAML::dump(review)
          end
        end
      end
      
    end
    
    parse(:verbose=>false)
    write_reviews_to_db(@parsed_reviews)
  end
  
  def search_url
    "#{@starting_url}#{@page * @page_size}"
  end
  
  # get rid of non-reviews
  def trim(key, string)
    forum_posts = []
    reviews.each_with_index do |r, i|
      if r[key][/#{string}/]
        forum_posts.push i
      end
    end

    forum_posts.each do |fp|
      reviews[fp] = nil
    end
    reviews.compact!
  end
  
  def to_s
    puts "#{self.title} - #{self.link}"
  end
  
  def parse(args)
    if !args[:verbose].nil?
      verbose = args[:verbose]
    end
    
    puts "Before trims: #{self.reviews.size}"
    
    # trim out forum posts
    self.trim(:title, "OpenForum")
    self.trim(:link, "\/civis\/")
    self.trim(:link, "\/phpbb\/")
    self.trim(:link, "\/gadgets/")

    # for some reason getting an author bio link in there
    self.trim(:link, "\/author\/")

    # unique the whole thing
    self.reviews.uniq!

    # sort by title
    self.reviews.sort_by! { |r| r[:title] }

    # unique based on titles, gets rid of mulipage hits
    # avoid ruby bug #4346 (uniq! after sort_by!)
    self.reviews = self.reviews.uniq { |e| e[:title] }
    puts "After trims: #{self.reviews.size}"

    self.reviews.each do |r|
      doc = Nokogiri::HTML.parse(Base64::decode64(r[:doc]))
      puts "-" * 50 if verbose
      puts r[:link] if verbose

      @titles = Array.new
      # style 1 (table with heading, bleh)
      if !doc.css('tbody').css('th')[1].nil?
        print "STYLE 2: " if verbose
        title = doc.css('tbody').css('th')[1].text.strip
        puts title if verbose
        @titles << title
      end

      # style 2 (nice game-info div)
      if !doc.css('.game-info').css('h3')[0].nil?
        print "STYLE 3: " if verbose
        title = doc.css('.game-info').css('h3')[0].text.strip
        puts title if verbose
        @titles << title
      end

      # style 3 (nothing really, title detection)
      # http://arstechnica.com/gaming/news/2007/02/7048.ars
      # Game Review: WiiPlay (Wii)
      if doc.css('title').text[/^Game Review:/]
        print "STYLE 1: " if verbose
        title = doc.css('title').text.split(":")[1].strip
        puts title if verbose
        @titles << title
      end

      # style 4 (even less, just some <em> text)
      # http://arstechnica.com/gaming/reviews/2010/04/plain-sighton-the-pc-low-gravity-suicidal-robot-ninjas.ars
      if doc.xpath('//div[@id="story"]/h2[@class="title"]').css('em').text.size > 0
        print "STYLE 4: " if verbose
        title = doc.xpath('//div[@id="story"]/h2[@class="title"]').css('em').text.strip
        puts title if verbose
        @titles << title
      end

      # style 5 (absolutely nothing useful)
      # Try to detect proper nouns after the word reviews
      # http://arstechnica.com/gaming/reviews/2010/03/retro-but-approachable-ars-review-mega-man-10.ars
      if !doc.xpath('//meta[@name = "title"]').empty?
        if doc.xpath('//meta[@name = "title"]').attr("content").to_s.size > 0

          title = doc.xpath('//meta[@name = "title"]').attr("content").to_s
          game_title = title[/reviews(.*)/]
          if !game_title.nil?
            title_array = game_title.split(" ")

            # get rid of any words that start with lower case, hopefully a title is left
            title_array.reject! { |e| e[/^[a-z]/] }
            game_title = title_array.join(" ")

            print "STYLE 5: " if verbose
            title = game_title
            puts title if verbose
            @titles << title
          end
        end
      end

      # style 6: grab title from text like Review: Lego Batman is saved by the co-op
      # http://arstechnica.com/gaming/news/2008/09/lego-batman-saved-by-the-co-op.ars
      if !doc.xpath('//meta[@property="og:title"]').empty?
        title = doc.xpath('//meta[@property="og:title"]').attr("content").to_s
        title_array = title.split(":")

        if !title_array[1].nil?
          game_title = title_array[1].strip
          game_title_array = game_title.split(" ")

          caps = Array.new
          game_title_array.each do |e|
            if e =~ /^[A-Z]/
              caps.push e
            else
              break
            end
          end

          print "STYLE 6: " if verbose
          title = caps.join(" ")
          puts title if verbose
          @titles << title
        end
      end

      hash = { :title => r[:title], :link => r[:link], :date => r[:date], :titles => @titles }
      self.parsed_reviews << hash
    end
  end
  
  def write_parsed
    File.open(File.dirname(__FILE__) + "/ars_parsed.yml", "w") do |file|
      self.parsed_reviews.each do |review|
        file.puts YAML::dump(review)
      end
    end
    puts "Dumped ars_parsed.yml"
  end
  
  def after(job)
    Jobstates.delete_all(:name => "scraper")
  end
    
end

####################################################
# MAIN


# s = Scraper.new
# s.scrape
# 
# s.parse(:verbose => false)
# s.write_parsed
