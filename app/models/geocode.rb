class Geocode < ActiveRecord::Base
  attr_accessible :geo_name_id, :latitude, :location_type_id, :longitude, :note, :precision_id, :project_id

  belongs_to :geo_name
  belongs_to :location_type
  belongs_to :precision
  belongs_to :project

  has_and_belongs_to_many :adms
end
