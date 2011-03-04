module ApplicationHelper
  
  def art_icon(id)
    return art_path(id, "icon")
  end

  def art_thumb(id)
    return art_path(id, "thumb")
  end

  def art_super(id)
    return art_path(id, "super")
  end
  
  def art_path(id, underscore_name)
    # TODO: we suck down any extension so this might break
    extensions = [ ".jpg", ".png", ".jpeg", ".gif" ]
    # use extensions array if so, else take this out.
    
    image_path = "images/art_cache/#{id}_#{underscore_name}.jpg"
    if File.exist? "public/#{image_path}"
      return image_tag "art_cache/#{id}_#{underscore_name}.jpg"
    else
      return image_tag '/images/no_art.png'
    end
  end
  
end
