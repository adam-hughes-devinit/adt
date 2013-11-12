class Verified < ActiveRecord::Base
  attr_accessible :name, :code, :export, :export_id
  include ProjectLevelCode

end
