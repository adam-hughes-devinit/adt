require 'spec_helper'

describe LoanDetail do
	let(:loan_detail){FactoryGirl.build(:loan_detail)}
	let(:usa) {FactoryGirl.create(:country, iso3: "USA")}
	let(:usd) {FactoryGirl.create(:currency, iso3: "USD",)}
	let(:easy_project) {FactoryGirl.build(:project, year: 2009, donor: usa)}
	let(:easy_transaction) {FactoryGirl.build(:transaction, value: 1000)}

	
	subject {loan_detail}
	

	describe "Should have a valid factory" do
		it {should be_valid}
	end


	describe "Should get its Grant Element Calculated" do
		before do 

			loan_detail.project = easy_project
			p = loan_detail.project

			p.transactions.each(&:destroy)
			easy_transaction.currency = usd
			p.transactions << easy_transaction

			p.year = 2009
			p.save!
			# p "Project: #{p.donor.iso3} - #{p.year} - #{p.usd_2009}"

		end

		it { should respond_to(:get_grant_element!)}

		describe "unless it's missing its maturity" do
			before do 
				loan_detail.maturity = nil
				loan_detail.get_grant_element!
			end

			its(:grant_element) {should be_nil}
		end


		describe "and it should match the example from the website" do
			# I grabbed the example from here
			
			# https://github.com/rmosolgo/aiddata-loan-calculator
			# calculate?value=1000&interest_rate=0.025&
			# discount_rate=0.1&maturity=10&grace_period=2.5


			before do
				loan_detail.interest_rate = 2.5
				loan_detail.maturity= 10
				loan_detail.grace_period = 2.5
				loan_detail.get_grant_element!
			end

			# Response from example:

			# {"present_value_of_repayments":667.62,
			# "present_value_of_disbursements":1000.0,
			# "grant_element_value":332.38,"grant_element_percent":0.3324,
			# "interest_rate":0.025,"discount_rate":0.1,"maturity":10.0,
			# "grace_period":2.5,"repayments_per_year":2}

			# is *100 in the model, so:
			its(:grant_element) {should eql(33.24)}
		end


	end

end