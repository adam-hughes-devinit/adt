class Country < ActiveRecord::Base
  
  attr_accessible :cow_code, :iso2, :iso3, :name, :oecd_code, :oecd_name

  validates :name, presence: true
  #validates :iso2, presence: true, uniqueness: true, length: {maximum: 2}
  #validates :iso3, presence: true, uniqueness: true, length: {maximum: 3}

end
