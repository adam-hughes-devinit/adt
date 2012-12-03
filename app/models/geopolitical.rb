class Geopolitical < ActiveRecord::Base
  attr_accessible :percent, :project_id, :recipient_id,  :subnational, :recipient, :region_id
  has_paper_trail
 
  has_many :flags, as: :flaggable, dependent: :destroy
  accepts_nested_attributes_for :flags
  
  belongs_to :project
  belongs_to :recipient, class_name: "Country"
end
