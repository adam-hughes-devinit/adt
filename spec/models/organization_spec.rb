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


	it {should respond_to(:devour!)}
	describe "can consume another organization" do
		let(:exim_bank) {FactoryGirl.create :organization, name: "Exim Bank"}
		let(:duplicate_exim_bank) {FactoryGirl.create :organization, name: "Also Exim Bank"}
		let(:first_project) {FactoryGirl.create :project}
		let(:second_project) {FactoryGirl.create :project}
		
		it "but only organizations" do
			expect {exim_bank.devour!(1)}.to raise_error(TypeError)
		end

		it "but not itself" do
			expect { exim_bank.devour! exim_bank}.to raise_error(RuntimeError)
		end
		

		describe "and participate in its projects" do
			before do
				first_project.participating_organizations << ParticipatingOrganization.new(organization: exim_bank)
				first_project.save!

				second_project.participating_organizations << ParticipatingOrganization.new(organization: duplicate_exim_bank)
				second_project.save!

				exim_bank.devour! duplicate_exim_bank
			end

			subject {exim_bank}
			
			it "should be participating in both projects" do
				exim_bank.projects.count.should equal(2)
			end
		end


		describe "unless that organization is a project owner" do
			before do
				second_project.owner = duplicate_exim_bank
				second_project.save!
			end

			it "shouldn't be able to devour orgs that own projects" do
				expect{ exim_bank.devour! duplicate_exim_bank}.to raise_error(RuntimeError)
			end

			it "should leave the projects alone" do
				second_project.owner.should eql(duplicate_exim_bank)
			end

		end

		describe "unless that organization has users" do 
			let(:some_user) { FactoryGirl.create :user, owner: duplicate_exim_bank}
			before do 
				some_user.save!
			end
			
			
			it "shouldn't be able to devour orgs with users" do
				expect{ exim_bank.devour! duplicate_exim_bank}.to raise_error(RuntimeError)
			end

			it "should leave the users alone" do
				some_user.owner.should eql(duplicate_exim_bank)
			end

		end

	end

end