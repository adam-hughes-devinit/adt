class Adm < ActiveRecord::Base
  attr_accessible :code, :name, :level, :geometry_id, :parent_id

  belongs_to :geometry
  has_many :geocodes
  has_many :children, class_name: "Adm", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Adm"
end
