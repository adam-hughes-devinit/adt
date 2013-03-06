class Organization < ActiveRecord::Base
  include OrganizationsHelper
  attr_accessible :description, :name, :organization_type_id, :organization_type
  has_paper_trail
  default_scope order: "name"
  after_save :destroy_organizations_hash
  after_destroy :destroy_organizations_hash

  def name_with_type
  	"#{self.name} (#{self.cached_organization_type_name })"
  end

  def cached_organization_type_name
    organization_types_hash =
      Rails.cache.fetch("global/organizationtypes", expires_in: 20.minutes ) do
        OrganizationType.all.map{ |ot| ot.as_json }
      end

    if type = organization_types_hash.select {|ot| ot["id"] == self.organization_type_id }[0] 
      type["name"]
    else
      "name not set"
    end
  end

  def as_json(options={})
    super(
      only: [:id,:name], 
      methods: [:name_with_type]
    ) 
  end


  belongs_to :organization_type
  has_many :participating_organizations
  has_many :origins, through: :participating_organizations
  has_many :projects, through: :participating_organizations
  has_many :owned_projects, class_name: "Project", foreign_key: "owner_id"
  has_many :users, foreign_key: "owner_id"
end
