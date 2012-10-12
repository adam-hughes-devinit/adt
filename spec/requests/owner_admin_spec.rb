require 'spec_helper'

describe "Owner and admin system" do
	let(:user){FactoryGirl.create(:user)}
	let(:project){FactoryGirl.create(:project)}
	let(:country){FactoryGirl.create(:country)}
	let(:status){FactoryGirl.create(:status)}
	subject { page }

	describe "unsigned visit to project page " do 
		before {visit project_path(project)}

		it {should have_content("Sign in")}
		it {should_not have_content("Edit this project")}
	end

	describe "unsigned visit to code page" do 
		before {visit country_path(country)}

		it {should have_content(country.name)}
		it {should_not have_content("Created_at")}
		it {should_not have_content("Edit")}
	end

	describe "unsigned visit to code index " do
		before {visit countries_path}
		it {should_not have_content("Edit")}
	end

	describe "unsigned visit to user page " do
		before {visit user_path(user)}
		specify {response.should redirect_to(signin_path)}
	end

	describe "unsigned visit to project index page" do
		before {visit projects_path}
		it {should_not have_content("Edit")}
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

			it {should_not have_content("Edit this project")}
		end
	end





end

