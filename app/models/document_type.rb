class DocumentType < ActiveRecord::Base
  attr_accessible :name
  has_paper_trail
  default_scope order: "name"	


  has_many :sources
  has_many :projects, through: :sources
end
