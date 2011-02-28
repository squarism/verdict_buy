class ArsReducer
  attr_accessor :parsed_file
  attr_accessor :reviews

  def initialize(parsed_file)
    @reviews = Array.new
    @parsed_file = parsed_file
  end

  def reduce
    # loop through yaml and load parsed reviews from ars
    YAML::load_documents(@parsed_file) do |doc|
      @reviews << doc
    end

    # ignore title arrays in yaml that are empty
    # TODO: audit results in case parser is wrong here
    @reviews.reject! {|r| r[:titles].empty?}
    
    clean_up! @reviews

    reduced = Array.new
    @reviews.each do |r|
      r[:titles_percent] = percentage_appears(r[:titles])
      reduced << r[:titles_percent]
    end
    
    reduced
  end

  # chance for reducer to clean up data
  def clean_up!(reviews)    
    # get rid of titles that are called "Ars" or empty
    reviews.each do |review|
      review[:titles].reject! { |title| title == "Ars" }
      review[:titles].reject! { |title| title == "" }
    end
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
