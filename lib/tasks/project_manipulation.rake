namespace :projects do
	desc "Recache all projects and total cache"
	task :recache => :environment do
	
		progress_bar = ProgressBar.new(Project.count)
		
		p "Caching individual projects"
		CACHE_ALL = false
		Project.all.each do |p| 
			p.cache!
			progress_bar.increment!
		end
		
		p "Remaking master cache"
		CACHE_ALL = true
		Project.first.cache!
		
		p "Finished Rechaching."
	end
end

