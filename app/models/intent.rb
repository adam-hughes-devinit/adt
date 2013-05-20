class Intent < ActiveRecord::Base
  attr_accessible :code, :description, :name, :id
  has_paper_trail
  default_scope order: "name"	


  has_many :projects
end
