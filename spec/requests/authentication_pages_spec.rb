require 'spec_helper'

describe "Authentication Pages" do
	subject { page}

	let(:sign_in_button) {"Sign in"}

	describe "signin page" do
		before { visit signin_path}
		it {should have_content(sign_in_button)}
    end

    describe "sign in" do
    	before { visit signin_path}

    	describe "with invalid information" do
    		before { click_button sign_in_button}

    		it {should have_content(sign_in_button)}
    		it {should have_content("Invalid")}
    	end
    	
    	describe "with valid information" do
    		let(:user) {FactoryGirl.create(:user)}
   
    		before do
    			fill_in "Email", with: user.email
    			fill_in "Password", with: user.password
    			click_button sign_in_button
       		end

       		it { should have_content(user.name)}
       		it { should have_link('Sign out', href: signout_path)}
       		it { should_not have_link('Sign in', href: signin_path)}

       		describe "followed by signout" do
       			before { click_link "Sign out"}
       			it {should have_link("Sign in")}
       		end


       	end

    end

end
