require 'spec_helper'

describe "User pages" do

	subject {page }
 
	let(:user) {FactoryGirl.create(:user)}
	
	describe "view a user" do
		before { visit user_path(user)}
		it {should have_content(user.name)}
		it {should have_content(user.email)}
	end

	describe "signup" do
		let(:submit) {"Create my account"}
		before { visit signup_path }

		it { should have_content("Sign up!")}

		describe "with no information" do			
			it "should not create a user" do
				expect { click_button submit }.not_to change(User, :count)
			end
		end

		describe "with valid information" do
			before do
				fill_in "Name", with: "Brian O'donnell"
				fill_in "Email", with: "bodonnell@aiddata.org"
				fill_in "Password", with: "foobar"
				fill_in "Password confirmation", with:"foobar"
			end

			it "should create a user " do
				expect { click_button submit }.to change(User, :count).by(1)
			end

			describe "after saving a user" do
				it { should have_link ('Sign out')}
			end
			
		end
	end

end
