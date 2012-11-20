class Flag < ActiveRecord::Base
  attr_accessible :comment, :flag_type, :flag_type_id, :flaggable_id, :flaggable_type, :owner_id, :owner, :source
  has_paper_trail
  
  belongs_to :flag_type
  belongs_to :flaggable, polymorphic: true
  belongs_to :owner, class_name: User
  
  def name
  	flag_type ? flag_type.name : source
  end
  	
  
  
end
