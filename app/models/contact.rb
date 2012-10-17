class Contact < ActiveRecord::Base
  attr_accessible :name, :organization_id, :position, :organization

  belongs_to :organization
  belongs_to :project
end
