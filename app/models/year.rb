class Year < ActiveRecord::Base
  attr_accessible :export, :year

  validates :year, presence: true, uniqueness: true

end
