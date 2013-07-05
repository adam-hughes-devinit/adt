require 'spec_helper'
include ProjectSpecHelper

describe "Project pages" do
	let(:project) {FactoryGirl.create :project, :aiddata, transactions: [], resources: []}
	let(:chinese_yuan) {FactoryGirl.create :currency, iso3: "CHN", name: "Chinese Yuan"}
	let(:aiddata_user) {FactoryGirl.create :user, :aiddata}
	let(:aiddata) {Organization.find_by_name("AidData")}
	let(:resource) {FactoryGirl.create :resource}



	SIGN_IN_TEXT = 'sign in'
	SAVE_TEXT = 'Save'
	subject {page}

	it "project should be AidData's" do
		project.owner.should eql(aiddata)
	end

	describe "aiddata user" do
		subject {aiddata_user}
		it {should be_valid}
		its(:owner) {should eql(aiddata)}

		describe "can sign in" do
			before do
				sign_in_aiddata_user
			end

			it {should_not have_content("Invalid")}
			it {should_not have_content("sign in")}

		end

	end



	describe "edit page" do


		describe "redirects to sign-in for strangers" do
			before do 
				visit edit_project_path(project)
			end

			it {should have_content(SIGN_IN_TEXT)}
		end

		describe "lets aiddata users" do
			before do
				sign_in_aiddata_user
			end

			describe "edit" do
				before do
					visit edit_project_path(project)
				end

				
				it {should have_title(project.title)}
				it {should have_selector("h1.page-header", text: "Edit")}
				it {should have_content("Active?")}
				it {should have_selector("input[type=submit][value='#{SAVE_TEXT}']")}

				describe "the title and description" do
					before do
						fill_in "project[title]", with: "New title!"
						fill_in "Description", with: "New description!"
						click_save
					end

					it {should have_title("New title!")}
					it {should have_content("New description!")}
				end

				describe "existing transactions" do
					before do
						project.transactions.create(value: 500, currency_id: chinese_yuan.id)
						visit edit_project_path(project)
						find(:css, '[name="project[transactions_attributes][0][value]"]').set 6789.10
						click_save
					end

					it {should have_content("6,789.10")}
				end

				describe "existing resources" do
					before do 
						project.resources << resource
						project.owner = aiddata

						project.save!
						visit edit_project_path(project)
						find(:css, '[name="project[resources_attributes][0][title]"]').set "New resource title"
						click_save
					end

					it {should have_content("New resource title")}
				end


			end
		end
	end
end




