class ParticipatingOrganization < ActiveRecord::Base
  attr_accessible :organization_id, 
  :role_id, :role, :origin_id, :origin, :project_id, :organization
  has_paper_trail
  
  has_many :flags, as: :flaggable, dependent: :destroy
  accepts_nested_attributes_for :flags

  belongs_to :organization
  belongs_to :role
  belongs_to :origin
  belongs_to :project
end
