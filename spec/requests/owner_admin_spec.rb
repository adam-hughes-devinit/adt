require 'spec_helper'

describe "Owner and admin system" do
	let(:user){FactoryGirl.create(:user)}
	let(:project){FactoryGirl.create(:project)}
	let(:country){FactoryGirl.create(:country)}
	let(:status){FactoryGirl.create(:status)}

	edit_project_link_text = "Edit this project"
	
	subject { page }

	describe "unsigned visit to project page " do 
		before do
			visit project_path(project)
		end

		it {should have_link("Sign in")}
		it {should_not have_link("Users")}

		it {should_not have_link(edit_project_link_text)}
	end

	describe "unsigned visit to code page" do 
		before {visit country_path(country)}

		it {should have_content(country.name)}
		it {should_not have_content("Created_at")}
		it {should_not have_link("Edit")}
	end

	describe "unsigned visit to code index " do
		before {visit countries_path}
		it {should_not have_link("Edit")}
	end

	describe "unsigned visit to user page " do
		before {visit user_path(user)}
		specify {response.should redirect_to(signin_path)}
	end

	describe "unsigned visit to project index page" do
		before {visit projects_path}
		it {should_not have_link("Edit")}
	end



	describe "unsigned attempts to change data" do

		describe "delete a code" do
			before { delete status_path(status)}
			specify {response.should redirect_to(signin_path)}
		end

		describe "delete a project" do
			before {delete project_path(project) }
			specify {response.should redirect_to(signin_path)}
		end
	end

	describe " sign in a non-owning user " do
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
		end

		describe "visit to users page" do
			before {visit users_path}
			it {should have_link("View")}
			it {should_not have_link("Add to #{user.owner.name}")}
		end

	end

	describe " sign in an owning user" do
		before do 

			project.update_attribute(:owner_id, user.owner.id)

			visit signin_path
			fill_in "Email", with: user.email
			fill_in "Password", with: user.password
			click_button "Sign in"
		end

		describe "visit a project page" do
			before { visit project_path(project)}

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
				unowned_user.owner = nil
				unowned_user.save!
				visit users_path
			end

			it {should have_content("#{User.last.name}")}
			it {should_not have_link("Add to #{user.owner.name}")}
		end

		describe "making an admin user" do
			before do
				user.toggle!(:admin)
				visit users_path
			end

				it {user.should be_admin}
				
				it {should have_link("Add to #{user.owner.name}")}

				it "should add the user to the organization" do
					expect { click_link "Add to #{user.owner.name}" }.to change(user.owner.users, :count).by(1)
				end
			 	
			 	describe "should show the new owner name " do
				 	before { visit user_path(User.last) }
				 	it {should have_content("#{user.owner.name}")}
				end

		end

	end

end

