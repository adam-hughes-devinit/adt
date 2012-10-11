class OrganizationType < ActiveRecord::Base
  attr_accessible :iati_code, :name

  has_many :organizations
  
  def projects
  	[]
  end

end
