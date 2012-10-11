require 'spec_helper' 

describe Source do
	let(:source) {FactoryGirl.create(:source)}

	subject {source}

	describe "have a valid Factory" do
		it { should be_valid}
	end

	# describe "have proper deflators"
end