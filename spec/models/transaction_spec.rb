require 'spec_helper' 

describe Transaction do
	let(:project) {FactoryGirl.create(:project, year: 2009)}
	let(:transaction) {FactoryGirl.create(:transaction, value: 1000)}
	let(:usd) {FactoryGirl.create(:currency, iso3: "USD")}

	subject {transaction}

	describe "have a valid Factory" do
		it { should be_valid}
	end

	describe "be deflatable" do
		before do 
			d = project.donor
			d.iso3 = "CHN" # gotta have a real iso3 for the deflator API
			d.save!
			transaction.currency = usd
			transaction.project = project
			transaction.save!
		end

		it {should be_valid}
		# I intentionally chose USD in year 2009 -- so these are the same.
		# but it will only save them if it successfully hits the deflator API.

		describe "to USD-2009" do
			its(:usd_defl) {should eql(transaction.value)}
		end

		describe "to USD-current" do
			its(:usd_current) {should eql(transaction.value)}
		end
	end
	
end