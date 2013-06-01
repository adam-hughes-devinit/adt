class Sector < ActiveRecord::Base
  attr_accessible :code, :name, :color
  include ProjectLevelCode
end

