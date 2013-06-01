class Verified < ActiveRecord::Base
  attr_accessible :name, :code
  include ProjectLevelCode

end
