class Geometry < ActiveRecord::Base
  attr_accessible :the_geom, :adm_code, :latitude, :longitude

  has_many :geocodes
  belongs_to :adms, :foreign_key => :adm_code, :primary_key => :code
  has_one :comment
end
