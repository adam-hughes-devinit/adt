class Geopolitical < ActiveRecord::Base
  attr_accessible :percent, :project_id, :recipient_id,  :subnational, :recipient, :region_id
  include ProjectAccessory

  belongs_to :recipient, class_name: "Country"
end
