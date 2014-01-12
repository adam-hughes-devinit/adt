class Language < ActiveRecord::Base
  attr_accessible :name

  has_many :resources
end
