class Adm < ActiveRecord::Base
  attr_accessible :code, :name, :level, :the_geom

  has_and_belongs_to_many :geocodes
end
