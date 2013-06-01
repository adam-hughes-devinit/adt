class FlowType < ActiveRecord::Base
  attr_accessible :aiddata_code, :iati_code, :name, :oecd_code
  include ProjectLevelCode

end
