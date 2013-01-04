class Sector < ActiveRecord::Base
  attr_accessible :code, :name, :color
  has_paper_trail
  default_scope order: "name"	

  has_many :projects
end
