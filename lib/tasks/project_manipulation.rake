namespace :projects do
	desc "Recache all projects and total cache"
	task :recache => :environment do
		CACHE_ALL = false
		Project.all.each(&:cache!)
		CACHE_ALL = true
		Project.first.cache!
		p "finished rechaching."
	end
end

