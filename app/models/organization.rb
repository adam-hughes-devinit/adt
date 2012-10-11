class Organization < ActiveRecord::Base
  attr_accessible :description, :name, :organization_type_id, :organization_type

  belongs_to :organization_type
  has_many :participating_organizations
  has_many :projects, through: :participating_organizations
end
