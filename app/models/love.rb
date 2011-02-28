class Love < ActiveRecord::Base
  belongs_to :ars_review
  has_many :ars_titles, :through => :ars_review
end
