require 'spec_helper' 

describe Organization do
	let(:organization) {FactoryGirl.create(:organization)}

	subject {organization}

	describe "have a valid Factory" do
		it { should be_valid}
	end

	# describe "have proper deflators"
end