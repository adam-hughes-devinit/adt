class Geocode < ActiveRecord::Base
  attr_accessible :geo_name_id, :precision_id, :project_id, :note

  belongs_to :geo_name
  belongs_to :precision
  belongs_to :project

  has_and_belongs_to_many :adms
end
