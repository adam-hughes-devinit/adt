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

	desc "Recalculate Grant Element for all Loan Details"
	task :recalculate_grant_element => :environment do
	
		progress_bar = ProgressBar.new(LoanDetail.where("maturity is not null").count)
		
		LoanDetail.where("maturity is not null").each do |ld| 
			ld.save!
			progress_bar.increment!
		end

	end
end

