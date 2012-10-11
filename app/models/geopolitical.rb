class Geopolitical < ActiveRecord::Base
  attr_accessible :percent, :project_id, :recipient_id,  :subnational

  belongs_to :project
  belongs_to :recipient, class_name: "Country"
end
