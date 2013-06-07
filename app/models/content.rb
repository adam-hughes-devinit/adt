class Content < ActiveRecord::Base
  attr_accessible :content, :name, :content_type
  
  has_paper_trail
  
  CONTENT_TYPES = [
  		"Page", # Markdown content
      "Complex Page", # Ruby content, must return HTML
      "Internal", # Markdown content
      # Used in building other views:
  		"Faculty/Staff",
      "Research Assistant",
  		"AidData Publication",
      "Affiliate Publication",
      "Other Publication",
      "News Article",
      "Blog Post"
       		
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

  def to_english
    "#{name.titleize}"
  end

  def page_content
    if content_type == "Complex Page" ||  content_type == "Page"
      require 'open-uri'
      app_root = Rails.env.production? ? "http://china.aiddata.org" : "http://localhost:3000" 
      pc = open("#{app_root}/content/#{name}"){|io| io.read}
    else
      pc = content
    end
    pc 
  end

  searchable if: proc { |c| ["Page", "Complex Page"].include?(c.content_type)} do 
    text :id, :name, :page_content, :content_type
  end
  

end
