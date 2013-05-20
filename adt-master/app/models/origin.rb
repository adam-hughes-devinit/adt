class Origin < ActiveRecord::Base
  attr_accessible :name
  has_paper_trail
  default_scope order: "name"	


  has_many :participating_organizations
  has_many :projects, through: :participating_organizations
end
