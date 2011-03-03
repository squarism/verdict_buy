class Love < ActiveRecord::Base
  belongs_to :ars_review
  has_many :ars_titles, :through => :ars_review
  
  # example: Love.all_validated.collect(&:gb_title)
  scope :all_validated, lambda {
    find(:all, :conditions => [ 'gb_title <> "<<NO GB HIT>>"' ] )
  }
  
end
