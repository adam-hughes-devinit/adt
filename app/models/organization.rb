class Organization < ActiveRecord::Base

  include OrganizationsHelper
  include IndexAndCacheHelper

  attr_accessible :description, :name, 
  :organization_type_id, :organization_type

  has_paper_trail
  default_scope order: "name"
  after_save :destroy_organizations_hash
  after_save :recache_and_reindex_this_organizations_projects
  after_destroy :destroy_organizations_hash

  def self.aiddata
    Rails.cache.fetch("organizations/aiddata", expires_in: 1.hour) do 
      Organization.find_by_name("AidData")
    end
  end

  def name_with_type
  	"#{self.name} (#{self.cached_organization_type_name })"
  end

  def cached_organization_type_name
    organization_types_hash =
      Rails.cache.fetch("global/organizationtypes") do
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
  delegate :name, to: :organization_type, allow_nil: true, prefix: true
  
  has_many :participating_organizations
  has_many :origins, through: :participating_organizations
  has_many :projects, through: :participating_organizations
  has_many :owned_projects, class_name: "Project", foreign_key: "owner_id"
  has_many :users, foreign_key: "owner_id"


  def recache_and_reindex_this_organizations_projects
     reindex_and_recache_by_associated_object self
  end


  def devour!(another_organization)
    raise TypeError, "You must pass another Organization!" unless another_organization.is_a? Organization
    raise RuntimeError, "You can't consume Organizations which own projects." if another_organization.owned_projects.any?    
    raise RuntimeError, "You can't consume Organizations which own users." if another_organization.users.any?

    Organization.transaction do
      another_organization.participating_organizations.each do |po|
        po.organization = self
        po.save!
      end
    end

  end
end
