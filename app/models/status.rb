class Status < ActiveRecord::Base
  attr_accessible :iati_code, :name

  has_many :projects
end
