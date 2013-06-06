class Source < ActiveRecord::Base
  attr_accessible :date, :document_type_id, :source_type_id, 
  :url, :project_id, :source_type, :document_type
  
  default_scope order: "date"

  include ProjectAccessory
  delegate :name, to: :source_type, allow_nil: true, prefix: true
  delegate :name, to: :document_type, allow_nil: true, prefix: true

  belongs_to :document_type
  belongs_to :source_type 
end
