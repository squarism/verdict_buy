# Artwork image cacher job.

# main image for a game is like this:
# giant_bomb_object -> image -> thumb_url => images/art_cache/thumb
# giant_bomb_object -> image -> super_url => images/art_cache/super

# giant_bomb_object -> images is an array of screenshots etc, don't need to use that.

class ArtworkWorker
  
  def update_all
    Love.all_with_gbid.each {|love| self.update(love.gb_id)}
  end
  
  def update(id)
    title = GiantLookup.new.find(id)
    thumb_image = title["image"]["thumb_url"]
    super_image = title["image"]["super_url"]
    icon_image = title["image"]["icon_url"]
    
    # save flag for status
    saved = false
    
    thumb_saved = self.save_image(thumb_image, "#{id}_thumb", "public/images/art_cache")
    super_saved = self.save_image(super_image, "#{id}_super", "public/images/art_cache")
    icon_saved = self.save_image(icon_image, "#{id}_icon", "public/images/art_cache")
    
    if thumb_saved || super_saved || icon_saved
      puts "Done saving images for #{title["name"]}."
    else
      puts "Skipped saving images for #{title["name"]}."
    end
  end

  def save_image(url, base_name, directory)
    # keep the remote extension
    file_extension = parse_extension(url)
    file_name = "#{base_name}#{file_extension}"

    if File.exist?(directory + "/" + file_name)
      # puts "Artwork.save_image(): Skipping file already downloaded"
      return false
    else
      # Get the response and data from the web for this image.
      response = Net::HTTP.get_response(URI.parse(url))

      # If the response is not nil, save the contents down to an image.
      if !response.nil?
        f = File.open(directory + "/" + file_name, "wb+")
        f << response.body
        f.close
        return true
      else
        puts "reponse is nil from #{url}:#{response}"
        raise Exception, "RESPONSE WAS NIL"
      end
    end
  end
  
  def parse_file_name(url)
    # Find the position of the last slash. Everything after it is our file name.
    spos = url.rindex("/")
    url[spos + 1, url.length - 1]
  end
  
  def parse_extension(url)
    url[url.rindex("."), url.length - 1]
  end
  
end

# thumb_image = "http://media.giantbomb.com/uploads/0/3715/672240-herzmg0f_thumb.jpg"
# puts Artwork.new.save_image(thumb_image, "11439", "public/images/art_cache/thumb")