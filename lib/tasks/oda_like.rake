namespace :projects do
	desc "Update FlowClass with old_oda_like"
	task :old_oda_like_to_flow_class => :environment do
	
		progress_bar = ProgressBar.new(Project.count)
		
		p "Updating new oda_like if it doesn't match the old oda_like..."
		
		CACHE_ALL=false
		Project.all.each do |p|
			if !(p.oda_like==p.old_oda_like) 
				p.oda_like=p.old_oda_like
				p.save
			end
			progress_bar.increment!
		end
		
		CACHE_ALL=true
		Project.first.save
		

	end
end

