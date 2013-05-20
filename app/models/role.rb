class Role < ActiveRecord::Base
  attr_accessible :iati_code, :name

  has_paper_trail
  default_scope order: "name"	


  has_many :participating_organizations
  has_many :projects, through: :participating_organizations
end
