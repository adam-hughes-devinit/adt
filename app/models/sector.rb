class Sector < ActiveRecord::Base
  attr_accessible :code, :name
  has_many :projects
end
