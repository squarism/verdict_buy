class ArsReview < ActiveRecord::Base
  has_many :ars_titles
  has_many :shop_list_items
  has_one :love
  
  # most likely title
  # TODO: need to trim out junk data that makes the title distribution 50/50
  def ars_title
    self.ars_titles.order('percent_appears desc').limit(1)
  end
end
