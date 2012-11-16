require 'spec_helper'

describe "Owner and admin system" do
	let(:user){FactoryGirl.create(:user)}
	let(:project){FactoryGirl.create(:project)}
	let(:country){FactoryGirl.create(:country)}
	let(:status){FactoryGirl.create(:status)}
	let(:organization){FactoryGirl.create(:organization)}
	let(:comment){FactoryGirl.build(:comment)}

	edit_project_link_text = "Edit this project"
	
	subject { page }

	describe "unsigned visit to project page " do 
		before do
			visit project_path(project)
		end


		it {should have_link("Sign in")}
		it {should_not have_link("Users")}

		it {should have_link("Codes")}
		it {should have_link("Projects")}
		it {should_not have_link(edit_project_link_text)}

		describe "should not be able to visit the edit project URL directly" do
			before {visit edit_project_path(project)}
			it {response.should redirect_to(projects_path)}
		end

		describe "should be able to create a comment" do
			before do
				visit project_path(project)
				fill_in "Name" , with: comment.name
				fill_in "Email", with: comment.email
				fill_in "Message", with: comment.content
				click_button "Submit"
			end

			it {should have_content(comment.content)}
		end
	end

	describe "unsigned visit to code page" do 
		before {visit country_path(country)}

		it {should have_content(country.name)}
		it {should_not have_content("Created_at")}
		it {should_not have_content("Updated_at")}
		it {should_not have_link("Edit")}

		describe "Should not even be able to go to edit code URL" do
			before { visit edit_country_path(country) }
			it {response.should redirect_to(countries_path)}
		end

	end

	describe "unsigned visit to code index " do
		before {visit countries_path}
		it {should_not have_link("Edit")}
	end	


	describe "unsigned visit to organization page" do 
		before {visit organization_path(organization)}

		it {should have_content(organization.name)}
		it {should_not have_content("Created_at")}
		it {should_not have_content("Updated_at")}
		it {should_not have_link("Edit")}
		it {should_not have_link("Destroy")}
	end

	describe "should not be able to visit the edit organization URL directly" do
		before {visit edit_organization_path(organization)}
		specify {response.should redirect_to(organizations_path)}
	end

	describe "unsigned visit to organization index " do
		before {visit organizations_path}
		it {should_not have_link("Edit")}
		it {should_not have_link("Destroy")}
	end

	describe "unsigned visit to user page " do
		before {visit user_path(user)}
		specify {response.should redirect_to(signin_path)}
	end

	# can't visit the projects_path without solr :/
	#
	# describe "unsigned visit to project index page" do
	#	 before {visit projects_path}
	#	 it {should_not have_link("Edit")}
	# end



	describe "unsigned attempts to change data" do

		describe "delete a code" do
			before { delete status_path(status)}
			specify {response.should redirect_to(signin_path)}
		end

		describe "delete an organization" do
			before { delete organization_path(organization)}
			specify {response.should redirect_to(signin_path)}
		end

		describe "delete a project" do
			before {delete project_path(project) }
			specify {response.should redirect_to(signin_path)}
		end
	end

	describe "sign in a non-owning user " do
		before do
			visit signin_path
			fill_in "Email", with: user.email
			fill_in "Password", with: user.password
			click_button "Sign in"
		end

		describe "signed visit to project page" do
			before {visit project_path(project)}
			it {should_not have_link("Sign in")}
			it {should have_link("Users")}
			it {should_not have_link(edit_project_link_text)}
			it {should_not have_content("Delete comment")}
		end

		describe "visit to users page" do
			before {visit users_path}
			it {should have_link("View")}
			it {should_not have_link("Add to #{user.owner.name}")}
		end

	end

	describe "sign in an owning user" do
		before do 
			project.update_attribute(:owner_id, user.owner.id)
			visit signin_path
			fill_in "Email", with: user.email
			fill_in "Password", with: user.password
			click_button "Sign in"
		end
		
		describe "visit user's profile" do
			before do 
				visit user_path(user)
			end
			it {should have_content(user.name)}
		end	

		describe "visit a project page" do
			before do
				visit project_path(project)
			end

			it {should have_content(user.owner.name)}
			it {should_not have_link("Sign in")}
			it {should have_link("Users")}
			it {should have_link(edit_project_link_text)}

		end

		describe "visit to users page" do
			before do 
				unowned_user = user.dup
				unowned_user.name= "Unowned User"
				unowned_user.email= "Unowneduser@aiddata.org"
				unowned_user.owner_id = nil
				unowned_user.save!
				visit users_path
			end

			it {should have_content("Unowned User")}
			it {should_not have_link("Add to #{user.owner.name}")}
		end

		describe "making an admin user" do
			before do
				user.toggle!(:admin)
				visit users_path
			end

			it {user.should be_admin}
			it {should have_link("Add to #{user.owner.name}")}
			it {should_not have_link("Remove from #{user.owner.name}")}

			it "should add the user to the organization" do
				expect { click_link "Add to #{user.owner.name}" }.to change(user.owner.users, :count).by(1)
			end
		 	
		 	describe "should show the new owner name " do
			 	before { visit user_path(User.last) }
			 	it {should have_content("#{user.owner.name}")}
			end

			describe "visit the project page" do
				before do
					project.comments << comment
					project.save!
					visit project_path(project)
				end

				it {should have_content(comment.content)}
				it {should have_content("Delete comment")}

				describe "should be able to delete a project" do
					before {click_link 'Delete comment'}
					it {should_not have_content(comment.content)}
				end
			end

		end

	end

end

