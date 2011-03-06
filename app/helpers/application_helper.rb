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
  def art_path(id, underscore_name)
    # TODO: adding other file types, this might break
    # extensions = [ ".jpg", ".png", ".jpeg", ".gif" ]

    # match any file in the image directory
    wildcard = "public/images/art_cache/#{id}_#{underscore_name}*"
    # we shouldn't have multiple files extensions for the same game so just grab first
    file_match = Dir[wildcard].first

    if file_match
      return image_tag file_match.sub(/^public\/images\//,'')
    else
      return image_tag "/images/no_art_#{underscore_name}.gif"
    end
  end
  
end
