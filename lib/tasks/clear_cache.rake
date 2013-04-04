namespace :caches do
	desc "Wipe everything"
	task :wipe => :environment do

		p "Clear key-value pairs like csv_text and scopes"
		Rails.cache.clear

		p "Clear cached pages like /projects/:id and /projects?..."
		controller = ActionController::Base.new

		progress_bar = ProgressBar.new(Project.count)
		
		Project.all.each do |p| 
			controller.expire_fragment %r{projects/#{p.id}.*} 
			progress_bar.increment!
		end
		
		controller.expire_fragment %r{.*index.*}

	end
end

