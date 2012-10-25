class Geopolitical < ActiveRecord::Base
  attr_accessible :percent, :project_id, :recipient_id,  :subnational, :recipient
  has_paper_trail
  
  belongs_to :project
  belongs_to :recipient, class_name: "Country"
end
