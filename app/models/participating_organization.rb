class ParticipatingOrganization < ActiveRecord::Base
  attr_accessible :organization_id, 
  :role_id, :role, :origin_id, :origin, :project_id, :organization
  include ProjectAccessory

  belongs_to :organization
  belongs_to :role
  belongs_to :origin

end
