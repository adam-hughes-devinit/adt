namespace :projects do
	desc "Recache all projects and total cache"
	task :recache => :environment do
	
		progress_bar = ProgressBar.new(Project.count)
		
		p "Caching individual projects"

		Project.all.each do |p| 
			p.cache_one!
			progress_bar.increment!
		end
		
		p "Remaking master cache"
		

		Project.all.sample.cache!
		
		p "Finished Rechaching."
	end
end

