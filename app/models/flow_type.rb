class FlowType < ActiveRecord::Base
  attr_accessible :aiddata_code, :iati_code, :name, :oecd_code
  has_paper_trail
  default_scope order: "name"	


  has_many :projects
end
