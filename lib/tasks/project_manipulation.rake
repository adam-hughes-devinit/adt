namespace :projects do
	desc "Recache all projects and total cache"
	task :recache => :environment do
		
		p "Project caching has been removed -- try `rake caches:wipe` to reset cached pages and data."
	
	end

	desc "Recalculate Grant Element for all Loan Details"
	task :recalculate_grant_element => :environment do
	
		progress_bar = ProgressBar.new(LoanDetail.where("maturity is not null").count)
		
		LoanDetail.where("maturity is not null").each do |ld| 
			ld.save!
			progress_bar.increment!
		end

	end
end

