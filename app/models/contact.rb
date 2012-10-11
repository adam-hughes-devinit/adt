class Contact < ActiveRecord::Base
  attr_accessible :name, :organization_id, :position

  belongs_to :organization
end
