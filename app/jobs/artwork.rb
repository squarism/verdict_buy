class Artwork
  
  def update_all
    
  end
  
  def update(id)
    title = GiantLookup.new.find(id)
    thumb_image = title["image"]["thumb_url"]
    super_image = title["image"]["super_url"]
    
    self.save_image(thumb_image, "#{id}_thumb", "public/images/art_cache")
    self.save_image(super_image, "#{id}_super", "public/images/art_cache")
    
  end


  def save_image(url, base_name, directory)
    # Parse the image name out of the url. We'll use that
    # name to save it down.
    #file_name = parse_file_name(url)
    
    # keep the remote extension
    file_extension = parse_extension(url)
    
    file_name = "#{base_name}#{file_extension}"

    if File.exist?(directory + "/" + file_name)
      puts "Artwork.save_image(): Skipping file already downloaded"
    else
      # Get the response and data from the web for this image.
      response = Net::HTTP.get_response(URI.parse(url))

      # If the response is not nil, save the contents down to
      # an image.
      if !response.nil?
        f = File.open(directory + "/" + file_name, "wb+")
        f << response.body
        f.close
      else
        puts "reponse is nil from #{url}:#{response}"
      end
    end
  end
  
  def parse_file_name(url)
    # Find the position of the last slash. Everything after
    # it is our file name.
    spos = url.rindex("/")
    url[spos + 1, url.length - 1]
  end
  
  def parse_extension(url)
    url[url.rindex("."), url.length - 1]
  end
  
  
  
end

# thumb_image = "http://media.giantbomb.com/uploads/0/3715/672240-herzmg0f_thumb.jpg"
# puts Artwork.new.save_image(thumb_image, "11439", "public/images/art_cache/thumb")