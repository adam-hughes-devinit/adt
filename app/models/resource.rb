class Resource < ActiveRecord::Base
	attr_accessible :authors, :dont_fetch, :download_url, 
	:fetched_at, :publish_date, :publisher, 
	:publisher_location, :resource_type, :title, :source_url

	validates_uniqueness_of :source_url
	validates_presence_of :source_url, :title, :authors
	RESOURCE_TYPES = ["Journal Article", "News Report"]
	validates_inclusion_of :resource_type, in: RESOURCE_TYPES

	before_save :fetch!

	def self.resource_types
		RESOURCE_TYPES
	end

	def to_citation
		# implement.
	end

	def fetch!
		self.fetched_at = Time.new
	  	unless dont_fetch
		  	
		  	# implement.
		end
	end
	handle_asynchronously :fetch!

end
