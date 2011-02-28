class ArsReducer
  attr_accessor :reviews

  def initialize
    @reviews = Array.new
  end

  def reduce(hash)
    @review = hash
    clean_up! @review
    percentage_appears(@review[:titles]) unless @review[:titles].size == 0
  end

  # chance for reducer to clean up data
  def clean_up!(review)    
    review[:titles].reject! { |title| title == "Ars" }
    review[:titles].reject! { |title| title == "" }
  end

  def percentage_appears(array)
    # hash of number of times string appears in array
    number_times_appears = Hash.new(0)

    array.each do |a|
      if !a.empty?
        number_times_appears[a] += 1
      end
    end

    # total is the denominator in percentage
    total = array.size.to_f

    percentage = Hash.new
    number_times_appears.each_key do |appears|
      percent = number_times_appears[appears].to_f / total
      percentage[appears] = (percent.round 2) * 100
    end

    # return hash like {"apple"=>75.0, "orange"=>25.0}
    percentage
  end
end

# test_hash = [
#   { :titles => [ "apple", "apple", "orange" ] },
#   { :titles => [ "blue", "red", "green" ] },
#   { :titles => [] },
#   { :titles => [ "one", "one", "one" ] }
# ]
# test_hash.each do |a|
#   p ArsReducer.new.reduce a
# end