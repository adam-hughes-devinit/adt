class OdaLike < ActiveRecord::Base
  attr_accessible :name, :code
  has_paper_trail
  default_scope order: "name"	

	has_many :flow_classes, class_name: "FlowClass", foreign_key: "oda_like_master_id"
  has_many :projects, through: :flow_classes
end
