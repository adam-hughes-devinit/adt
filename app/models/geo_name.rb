class GeoName < ActiveRecord::Base
  attr_accessible :name, :code

  has_many :geocodes
end
