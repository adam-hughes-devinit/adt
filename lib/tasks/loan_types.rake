namespace :projects do
	desc "Create Loan Types"
	task :create_loan_types => :environment do
	
    ["Interest-Free", "Concessional", "Non-Concessional", "No Information"].each do |n|
      LoanType.create!(name: n)
    end

	end
end

