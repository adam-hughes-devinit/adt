namespace :projects do
	desc "Recache all projects and total cache"
	task :recache => :environment do
	
		progress_bar = ProgressBar.new(Project.count)
		
		p "Caching individual projects now"

		Project.all.each do |p| 
			p.cache! now: true
			progress_bar.increment!
		end
		
		p "Finished Rechaching."
	end
end

