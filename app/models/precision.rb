class Precision < ActiveRecord::Base
  attr_accessible :code, :description

  has_many :geocodes
end
