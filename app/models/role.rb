class Role < ActiveRecord::Base
  attr_accessible :iati_code, :name

  has_many :participating_organizations
  has_many :projects, through: :participating_organizations
end
