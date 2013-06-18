module ResourceSearchable
	extend ActiveSupport::Concern

	def project_titles
		projects.map(&:title)
	end

	included do		

		searchable do 
				text :title, :authors, :publisher_location, 
				:publisher, :source_url, :id, :resource_type
				text :project_titles
				string :resource_type
				string :project_ids, multiple: true
				string :publisher
		end

		handle_asynchronously :solr_index if Rails.env.production?
	end


end