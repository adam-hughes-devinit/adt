class Intent < ActiveRecord::Base
  attr_accessible :code, :description, :name, :id
  include ProjectLevelCode
end
