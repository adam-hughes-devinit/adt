class GeoName < ActiveRecord::Base
  attr_accessible :name, :code, :latitude, :longitude, :the_geom, :location_type_id

  has_many :geocodes
end
