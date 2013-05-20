class Verified < ActiveRecord::Base
  attr_accessible :name, :code
  has_paper_trail
  default_scope order: "name"	

  has_many :projects
end
