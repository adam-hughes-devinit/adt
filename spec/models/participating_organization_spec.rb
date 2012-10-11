require 'spec_helper' 

describe ParticipatingOrganization do
	let(:participating_organization) {FactoryGirl.create(:participating_organization)}

	subject {participating_organization}

	describe "have a valid Factory" do
		it { should be_valid}
	end

end