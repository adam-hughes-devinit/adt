namespace :projects do
	desc "Migrate sources to Resources"
	task :sources_to_resources => :environment do

		progress_bar = ProgressBar.new(Source.count)

		sources_data = {}
		spreadsheet = Rails.root.join "lib/tasks/sources_data.csv"
		p spreadsheet
		CSV.foreach(spreadsheet, col_sep: "\t", headers: true) do |row|
			sources_data["#{row["source_id"]}"] = {
				title: row["headline"],
				publisher: row["agency"]
			}
		end
		p sources_data["2676"]


 		Source.find_each do |source|
			
			if source.url.present? && source.project.present?
				resource = Resource.find_or_initialize_by_source_url(source.url)
				
				if resource.publish_date.blank?
					resource.publish_date = source.date 
				end

				if resource.new_record? 
					source_metadata = sources_data["#{source.id}"] || {}

					resource.title = source_metadata[:title] || "#{source.url}"
					resource.authors = source_metadata[:publisher] 
					resource.publisher = source_metadata[:publisher]
					resource.resource_type = "Other"

					resource.dont_fetch = true if resource.source_url.downcase =~ /factiva/
				end


				resource.projects << source.project
				resource.save!
			end
			progress_bar.increment!

		end
	end

	desc "Flush resources"
	task :flush_resources => :environment do

		progress_bar = ProgressBar.new(Resource.count)
		
		Resource.all.each do |r|
			r.destroy
			progress_bar.increment!
		end

	end

end
