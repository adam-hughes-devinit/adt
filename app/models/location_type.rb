class LocationType < ActiveRecord::Base
  attr_accessible :name, :code, :description

  has_many :geocodes
end
