class Country < ActiveRecord::Base
  attr_accessible :cow_code, :iso2, :iso3, :name, :oecd_code, :oecd_name

  validates :name, presence: true
  
end
