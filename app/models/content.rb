class Content < ActiveRecord::Base
  attr_accessible :content, :name, :chinese_name, :content_type, :chinese_content
  
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
    "#{name.titleize} #{chinese_name.present? ? "(#{chinese_name})" : ""}"
  end

  def page_content
    if content_type == "Complex Page" 
      if persisted?
        require 'open-uri'
        app_root = Rails.env.production? ? "http://china.aiddata.org" : "http://localhost:3000" 
        pc = open("#{app_root}/content/#{CGI::escape(name)}"){|io| io.read}
      else
        pc = content
      end
    elsif  content_type == "Page"
      pc = Markdown.new(content).to_html
      pc << Markdown.new(chinese_content).to_html      
    else
      pc = content
    end
    pc 
  end

  searchable if: proc { |c| ["Page", "Complex Page"].include?(c.content_type)} do 
    text :id, :name, :chinese_name, :page_content, :content_type
  end
  

end
