class OrganizationType < ActiveRecord::Base
  attr_accessible :iati_code, :name
  has_paper_trail
  default_scope order: "name"	
  after_save :wipe_organization_type_name_cache

  has_many :organizations
  
  # Stub this method out
  # so that I can still use the default view
  def projects
  	[]
  end

  def wipe_organization_type_name_cache
  	Rails.cache.delete("global/organizationtypes")
  end
  

end
