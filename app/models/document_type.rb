class DocumentType < ActiveRecord::Base
  attr_accessible :name

  has_many :sources
  has_many :projects, through: :sources
end
