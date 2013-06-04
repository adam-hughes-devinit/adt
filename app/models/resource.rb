class Resource < ActiveRecord::Base
	
	include AmazonHelper

	attr_accessible :authors, :dont_fetch, :download_url, 
	:fetched_at, :publish_date, :publisher, 
	:publisher_location, :resource_type, :title, :source_url,
	:project_ids

	validates_uniqueness_of :source_url
	validates_presence_of :source_url, :title, :authors
	RESOURCE_TYPES = [
		"Government Source (Donor/Recipient)",
		"Implementing/Intermediary Agency Source",
		"Other Official Source (non-Donor, non-Recipient)",
		"NGO/Civil Society/Advocacy",
		"Acacemic Journal Article", 
		"Other Academic (Working Paper, Dissertation)",
		"Media Report, including Wikileaks",
		"Social Media, including Unofficial Blogs",
		"Other"
	]


	validates_inclusion_of :resource_type, in: RESOURCE_TYPES

	after_save :fetch!, if: Proc.new {|r| r.source_url_changed? }

	has_and_belongs_to_many :projects

	def self.resource_types
		RESOURCE_TYPES
	end

	def to_citation
		# Author's last name, first name. Book title. Additional information. City of publication: Publishing company, publication date.
		# Author's last name, first name. "Title of Article." Title of Encyclopedia. Date. 
		# Author's last name, first name. "Article title." Periodical title Volume # Date: inclusive pages. 

		"#{authors}.\"#{title}.\" <i>#{publisher}</i>. #{publish_date}. Accessed: #{dont_fetch ? created_at : fetched_at}. <a href='#{source_url}'>#{source_url}</a>.".html_safe
	end

	def fetch!
		update_column :fetched_at, nil
		update_column :download_url, nil
		new_fetched_at = Time.new
	  	if !(dont_fetch) && source_url[0..3]=='http'
	  		require 'open-uri'

	  		begin 
	  			resource_copy = open(source_url) 
	  			# pull the last bit from the URL
	  			s3_filename = source_url.gsub(/^.*\/(.*)$/, '\1')
	  			
	  			# if pulling name from URL doesn't work:
	  			s3_filename = "#{id}_#{title.gsub(/[\s]/, '_')}" if s3_filename.blank?
	  			
	  			p "RESOURCE: Saving #{s3_filename} from #{source_url}"
 				filename = s3_upload "china_resources", resource_copy, s3_filename
 				new_download_url = "http://s3.amazonaws.com/china_resources/#{s3_filename}"
 			rescue Exception => e 
 				p e.message
 				new_download_url = nil
 			end
		end

		self.update_column :fetched_at, new_fetched_at 
		self.update_column :download_url, new_download_url
	end
	handle_asynchronously :fetch!

end
