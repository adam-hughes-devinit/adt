class Organization < ActiveRecord::Base
  attr_accessible :description, :name, :organization_type_id, :organization_type
  has_paper_trail
  default_scope order: "name"

  def name_with_type
  	"#{self.name} (#{self.organization_type.blank? ? '' : self.organization_type.name})"
  end

  belongs_to :organization_type
  has_many :participating_organizations
  has_many :origins, through: :participating_organizations
  has_many :projects, through: :participating_organizations
  has_many :owned_projects, class_name: "Project", foreign_key: "owner_id"
  has_many :users, foreign_key: "owner_id"
end
