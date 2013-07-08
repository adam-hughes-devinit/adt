require 'spec_helper' 

describe Organization do
	let(:organization) {FactoryGirl.create(:organization)}
	let(:project) {FactoryGirl.build :project}
	let(:user) {FactoryGirl.build :user}

	subject {organization}

	describe "have a valid Factory" do
		it { should be_valid}
	end

	describe "can participate in projects" do
		
		before do 
			p_o = ParticipatingOrganization.new(organization: organization)
			project.participating_organizations << p_o
			project.save!
		end

		it "should be in the project's organizations" do
			project.participating_organizations.map(&:organization_id).should include(organization.id)
		end

		its(:projects){should include(project)}
	end

	describe "can own projects" do
		before do
			project.owner = organization
			project.save!
		end

		it "should be the project's owner" do
			project.owner.should eql(organization)
		end

		its(:owned_projects) {should include(project)}

	end

	describe "can own users" do
		before do 
			user.owner = organization
			user.save!
		end

		its(:users){should include(user)}
	end



end