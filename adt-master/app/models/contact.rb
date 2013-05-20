class Contact < ActiveRecord::Base
  attr_accessible :name, :organization_id, :position, :organization, :project_id
  has_paper_trail
  
  has_many :flags, as: :flaggable, dependent: :destroy
  accepts_nested_attributes_for :flags

  belongs_to :organization
  belongs_to :project
end
