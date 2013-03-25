require 'spec_helper'

describe "Following and Feed" do
=begin

	commented out because this feature was not implemented
	
	let(:organization){FactoryGirl.create(:organization){name: "AidData"}}
	let(:sector){FactoryGirl.create(:sector)}
	let(:user){FactoryGirl.create(:user)}
	let(:project){FactoryGirl.create(:project)}
	before do
		user.update_attribute(:owner, organization)
		project.update_attribute(:owner, organization)
		another_user = User.create(name: "Another User", 
									email: "Another@user.com",
									password: "foobar",
									password_confirmation: "foobar",
									owner: organization)
	end

	subject { user }

	it {should respond_to :feed}

	it "Should be able to follow another user" do
		expect { user.follow!(another_user)}.to change(user.followed_all, :count).by(1)
	end
	
	it "Should be able to follow a project" do
		expect { user.follow!(another_user)}.to change(user.followed_all, :count).by(1)
	end

	describe "having a feed with changes from followed items" do
		before do 
			# Sign in another User
			visit signin_path
			fill_in "Email", with: another_user.email
			fill_in "Password", with: another_user.password
			click_button "Sign in"
			# Edit a code
			visit edit_sector_path(sector)
			fill_in "Name", with: "New sector name"
			click_button "Save"

			# Edit the project
			visit edit_project_path(project)
			fill_in "Description", with: "New project description"
			# including accessory data
			click_link "Add a Transaction"
			fill_in "Value", with: 500
			select "Chinese Yuan", from: "Currency"
			click_button "Save"

			# Create a project
			visit new_project_path
			fill_in "Title", with: "Second project title"
			click_button "Save"

			click_link "Sign out"

			# sign in the other user
			visit signin_path
			fill_in "Email", with: user.email
			fill_in "Password", with: user.password
			click_button "Sign in"
			visit root_path
		end
			it {should have_selector("div", id: "activity-feed")}
			it {should have_content("Second project title")}
			it {should have_content(project.title)}
			it {should have_content("New sector name")}
	end


	it "Should be able to unfollow another user" do
		expect { user.unfollow(another_user)}.to change(user.followed_all, :count).by(1)	
	end

	it "Should be able to follow a project" do
		expect { user.unfollow!(project)}.to change(user.followed_all, :count).by(1)
	end

	describe "the feed shouldn't have unfollowed news in it" do
			it {should_not have_content("Second project title")}
			it {should_not have_content(project.title)}
			it {should_not have_content("New sector name")}
	end
=end

end
