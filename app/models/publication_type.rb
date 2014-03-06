class PublicationType < ActiveRecord::Base
  attr_accessible :name

  has_many :publications
end
