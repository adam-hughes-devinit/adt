class Geometry < ActiveRecord::Base
  attr_accessible :the_geom, :adm_code

  has_many :geocodes
  belongs_to :adms, :foreign_key => :adm_code, :primary_key => :code
end
