require 'spec_helper' 

describe Transaction do
	let(:transaction) {FactoryGirl.create(:transaction)}

	subject {transaction}

	describe "have a valid Factory" do
		it { should be_valid}
	end

	# describe "have proper deflators"
end