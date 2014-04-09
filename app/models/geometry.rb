class Geometry < ActiveRecord::Base
  attr_accessible :the_geom

  has_many :geocodes
  belongs_to :adms, :foreign_key => :adm_code, :primary_key => :code
end
