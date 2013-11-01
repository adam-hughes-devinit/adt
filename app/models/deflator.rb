class Deflator < ActiveRecord::Base
  belongs_to :country
  attr_accessible :value, :year, :country_id
end
