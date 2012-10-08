require 'spec_helper'

describe "Static Pages" do

	subject { page }
	describe "Home page" do
		before { visit '/static_pages/home'}
		it { should have_content("AidData MBDC")}
	end
end
