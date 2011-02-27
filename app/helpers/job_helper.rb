module JobHelper
  def shorten_last_error(message)
    if !message.nil?
      first_line = message.split("\n")[0]
      return first_line[1..message.length]
    else
      "No Errors."
    end
  end
    
end
