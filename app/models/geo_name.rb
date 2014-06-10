class GeoName < ActiveRecord::Base
  attr_accessible :name, :code, :latitude, :longitude, :location_type_id

  has_many :geocodes
  belongs_to :location_type

  searchable do
    text :name
    string :name
  end
end
