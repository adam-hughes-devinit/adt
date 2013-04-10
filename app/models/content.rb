class Content < ActiveRecord::Base
  attr_accessible :content, :name, :content_type
  
  has_paper_trail
  
  CONTENT_TYPES = [
  		"Page",
  		#"Team Member",
  		#"AidData Publication",
      #"Other Publication"   		
  	]

  validates_inclusion_of :content_type, in: CONTENT_TYPES

  def data
  	YAML.load(content)
  end

end
