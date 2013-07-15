class Contact < ActiveRecord::Base
  attr_accessible :name, :organization_id, :position, :organization, :project_id
  include ProjectAccessory

  belongs_to :organization
  delegate :name, to: :organization, allow_nil: true, prefix: true

  def to_english
  	"#{name.present? ? "#{name}, " : "" }#{position.present? ? "#{position} " : ""}#{organization_name.present? ? "(#{organization_name})" : "" }"
  end
  
end
