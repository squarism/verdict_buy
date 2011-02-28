class ArsReview < ActiveRecord::Base
  has_many :ars_titles
  has_many :shop_list_items
  has_one :love
end
