class Status < ActiveRecord::Base
  attr_accessible :iati_code, :name, :code
  include ProjectLevelCode

end
