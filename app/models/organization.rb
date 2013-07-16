class Organization < ActiveRecord::Base

  include IndexAndCacheHelper

  attr_accessible :description, :name, 
  :organization_type_id, :organization_type

  has_paper_trail
  default_scope order: "name"
  after_save :destroy_organizations_hash
  after_save :recache_and_reindex_this_organizations_projects

  def self.aiddata
    Rails.cache.fetch("/organizations/aiddata", expires_in: 1.hour) do 
      Organization.find_by_name("AidData")
    end
  end

  def name_with_type
    "#{self.name} (#{self.organization_type_name })"
  end

  def to_english
    "#{self.name} (#{self.organization_type_name}), #{self.projects.count} projects."
  end

  def self.organizations_hash
    Rails.cache.fetch('/organizations/all') do 
      Organization.all.map {|o| { id: o.id, name: o.name_with_type } }
    end   
  end

  def destroy_organizations_hash
    Rails.cache.delete('/organizations/all')
  end


  def as_json(options={})
    super(
      only: [:id,:name], 
      methods: [:name_with_type]
    ) 
  end


  belongs_to :organization_type
  delegate :name, :iati_code, to: :organization_type, allow_nil: true, prefix: true
  
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
    raise RuntimeError, "Organization can't consume itself!" if another_organization == self
    raise RuntimeError, "You can't consume Organizations which own projects." if another_organization.owned_projects.any?    
    raise RuntimeError, "You can't consume Organizations which own users." if another_organization.users.any?

    affected_projects = []
    Organization.transaction do
      another_organization.participating_organizations.each do |po|
        po.organization = self
        po.save!
        affected_projects << po.project unless affected_projects.include? po.project
      end
      Sunspot.index!(affected_projects)


      another_organization.destroy
    end
  end

  def as_json(options)
    super(
      methods: [:to_english, :projects]
    )
  end


  searchable do
    text :to_english, :name, :organization_type_name, :id
    text do
      projects(&:to_english)
    end
    string :organization_type_name
    string :origins, multiple: true
  end


end
