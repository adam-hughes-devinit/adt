class Contact < ActiveRecord::Base
  attr_accessible :name, :organization_id, :position, :organization
  has_paper_trail
  belongs_to :organization
  belongs_to :project
end
