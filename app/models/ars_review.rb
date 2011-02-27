class ArsReview < ActiveRecord::Base
  has_many :game_titles
  has_many :shop_list_items
  has_many :loves
end
