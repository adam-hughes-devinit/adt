module ResourceSearchable
	extend ActiveSupport::Concern

	def project_titles
		projects.map(&:title)
	end

	def url_searchable
		source_url.gsub(/[:.\/\?=_]/, " ")
	end


	included do		

		searchable do 
				text :title, :authors, :publisher_location, 
				:publisher, :source_url, :id, :resource_type,
				:url_searchable, :project_titles
				string :resource_type
				string :project_ids, multiple: true
				string :publisher
				string :title
        integer :language_id
				integer :projects_count
        date :fetched_at
		end
		
        # Nice idea, but I need it to show up in the search bar ~pronto~
		# handle_asynchronously :solr_index if Rails.env.production?
	end


end