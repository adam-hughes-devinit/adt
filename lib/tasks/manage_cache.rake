namespace :caches do
	desc "Wipe everything"
	task :wipe => :environment do

		p "Clear key-value pairs like csv_text and scopes"
		Rails.cache.clear



		progress_bar = ProgressBar.new(Project.count)
		p "Run sweeper for each project"

		Project.all.each do |p| 
		
			ProjectSweeper.instance.expire_cache_for(p)
			progress_bar.increment!
		end


	end
	
	desc "Test ALL Csv texts"
	task  :load_csv_texts => [:load_active_csv_texts, :load_inactive_csv_texts]

	desc "Load CSV Texts"
	task :load_active_csv_texts => :environment do
		p "Creating CSV texts"
		
		projects = Project.where("active = true ")

		progress_bar = ProgressBar.new(projects.count)
		p "Load text for each project"
		projects.each do |p| 
			
			p.csv_text
			progress_bar.increment!
		end
	end
	
	desc "Load CSV Texts"
	task :load_inactive_csv_texts => :environment do
		p "Creating CSV texts"
		
		projects = Project.where("active = false ")

		progress_bar = ProgressBar.new(projects.count)
		p "Load text for each project"
		projects.each do |p| 
			
			p.csv_text
			progress_bar.increment!
		end
	end
end

