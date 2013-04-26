class Content < ActiveRecord::Base
  attr_accessible :content, :name, :content_type
  
  has_paper_trail
  
  CONTENT_TYPES = [
  		"Page", # Markdown content
      "Complex Page", # Ruby content, must return HTML
      "Internal", # Markdown content
  		"Faculty/Staff",
      "Research Assistant",
  		"AidData Publication",
      "Affiliate Publication",
      "Other Publication",
      "News Article" 
       		
  	]

  validates_inclusion_of :content_type, in: CONTENT_TYPES

  def data
    
    begin
      data = YAML.load(content)
    rescue
      # in case YAML is malformed
      data = {}
    end

    data
  end

end
