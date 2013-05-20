require 'spec_helper' 

describe Geopolitical do
	let(:geopolitical) {FactoryGirl.create(:geopolitical)}

	subject {geopolitical}

	describe "have a valid Factory" do
		it { should be_valid}
	end

	# describe "have proper deflators"
end