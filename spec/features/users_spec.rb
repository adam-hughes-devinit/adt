require 'spec_helper'
include ProjectSpecHelper

describe "User permissions" do
	let(:china) {FactoryGirl.create :country, name: "China", iso3: "CHN", iso2: "CN"}
	let(:aiddata) {Organization.find_or_create_by_name("AidData")}
	let(:aiddata_user) {FactoryGirl.create :user, owner: aiddata }
	let(:project) {FactoryGirl.create :project, owner: aiddata, donor: china}

	subject {page} 


	describe "aiddata user" do
		subject {aiddata_user}
		it {should be_valid}
		its(:owner) {should eql(aiddata)}

		describe "can sign in" do
			before do
				sign_in_aiddata_user
			end

			subject {page}
			
			it {should_not have_content("Invalid")}
			it {should_not have_content("sign in")}

			describe "then edit projects" do
				before do
					project.save!
					visit edit_project_path(project)
				end

				it {should_not have_content("sign in")}
				it {should have_title("Edit")}
				it {should have_selector("h1", text: /Edit/)}
			end

			describe "then view pending content" do
				before { visit pending_content_path }

				it {should_not have_content("sign in")}
				it {should have_selector("h1", text: "Pending Content")}
			end


		end

	end

end
