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
  
  # get an image with a _icon _super _whatever bit of text in it
  # if no file is there, return a placeholder that follows this naming
  # convention.
  def art_path(love, underscore_name)
    # TODO: adding other file types, this might break
    # extensions = [ ".jpg", ".png", ".jpeg", ".gif" ]

    #love = Love.find(id)

    # match any file in the image directory
    wildcard = "public/images/art_cache/#{love.gb_id}_#{underscore_name}*"
    # we shouldn't have multiple files extensions for the same game so just grab first
    file_match = Dir[wildcard].first
    
    # alt tag text bit
    # love_title = love.gb
    # love_title = Love.where(:gb_id => love.gb_id).first
    if !love.gb_title = "<<NO GB HIT>>"
      alt_tag = love.gb_title
    else
      alt_tag = love.ars_review.ars_title
    end
    puts alt_tag

    if file_match
      return image_tag file_match.sub(/^public\/images\//,''), :title => alt_tag
    else
      return image_tag "/images/no_art_#{underscore_name}.gif", :title => alt_tag
    end
  end
  
end
