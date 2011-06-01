class ArsReview < ActiveRecord::Base
  has_many :ars_titles
  has_many :shop_list_items
  has_one :love
  
  # most likely title
  # TODO: need to trim out junk data that makes the title distribution 50/50
  def ars_title
    self.ars_titles.order('percent_appears desc').limit(1).first.title
  end
  
  def valid_title?
    if self.love.gb_title != "<<NO GB HIT>>" || self.love.gb_title.nil?
      return false
    else
      return true
    end
  end
  
  def self.with_valid_titles
    a = self.all
    a.reject{|r| r.valid_title? == false}
    a
  end

  def self.with_invalid_titles
    a = self.all
    a.reject{|r| r.valid_title? == true}
    a
  end

  
end
