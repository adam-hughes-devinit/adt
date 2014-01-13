class Language < ActiveRecord::Base
  attr_accessible :name, :code

  has_many :resources
end
