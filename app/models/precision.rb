class Precision < ActiveRecord::Base
  set_primary_key "code"
  attr_accessible :code, :description

  has_many :geocodes
end
