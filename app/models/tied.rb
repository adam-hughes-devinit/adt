class Tied < ActiveRecord::Base
  attr_accessible :iati_code, :name
  has_paper_trail
  default_scope order: "name"	

  has_many :projects
end
