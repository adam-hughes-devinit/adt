class Geometry < ActiveRecord::Base
  attr_accessible :the_geom

  has_many :geocodes
  has_many :adms
end
