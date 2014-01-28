class Precision < ActiveRecord::Base
  attr_accessible :code, :info

  has_many :geocodes
end
