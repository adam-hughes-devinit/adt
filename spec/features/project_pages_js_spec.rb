require 'spec_helper'
include ProjectSpecHelper

describe "Project pages", js: true do
	# Aw geez, I set up FactoryGirl traits,
	# but I can't use them here because
	# `js: true` tests use their own test instance, 
	# and don't see the objects created in those traits.
	let(:chinese_yuan) {FactoryGirl.create :currency, iso3: "CHN", name: "Chinese Yuan"}
	let(:china) {FactoryGirl.create :country, name: "China", iso3: "CHN", iso2: "CN"}
	let(:aiddata_user) {FactoryGirl.create :user,  owner: aiddata}
	let(:aiddata) {Organization.find_or_create_by_name("AidData")}
	let(:project) {FactoryGirl.create :project, owner: aiddata, donor: china, transactions: [], resources: []}
	let(:resource) {FactoryGirl.create :resource}
	let(:existing_resource) {FactoryGirl.create :resource, title: "Existing Resource"}

	before do 
		sign_in_aiddata_user
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
	subject {page}

	describe "edit pages"  do
		before do
			visit edit_project_path(project)
		end
	
		it {should have_content("Resources")}
		it {should have_content("Transactions")}

		describe "can create new transactions" do
			before do
				within "#project-form-transactions" do
					find('.add-one').click
				end
				find(:css, '[name^="project[transactions_attributes]"][name$="[value]"]').set 12345.67
				click_save
			end

			it {should have_content("12,345.67")}
		end

		describe "can edit resources" do


			describe "by making new ones" do
				before do
					within "#project-form-resources" do
						find('.add-one').click
					end	
					find(:css, %{[name^="project[resources_attributes]"][name$="[title]"]}).set("CHINESE NEWSPAPER")
					find(:css, %{[name^="project[resources_attributes]"][name$="[source_url]"]}).set("www.china.com")
					within %{[name^="project[resources_attributes]"][name$="[resource_type]"]} do
						select "Other"
					end

					click_save
				end

				it {should have_content("CHINESE NEWSPAPER")}
			end



			describe "by editing attached ones" do
				before do 
					project.resources << existing_resource
					project.save!
					visit edit_project_path(project)
				end
				
				it "should have a form for the resource" do
					title_input = page.find(:css, %{[name^="project[resources_attributes]"][name$="[title]"]})
					title_input.value.should eql("Existing Resource")
				end	

				describe "and clicking save" do
					before do
						find(:css, %{[name^="project[resources_attributes]"][name$="[title]"]}).set("NEW CHINESE NEWSPAPER")
						click_save
					end

					it {should have_content("NEW CHINESE NEWSPAPER")}
				end

			end

			describe "by attaching exiting ones" do
				before do
					existing_resource.save!
					existing_resource_id = existing_resource.id
					visit edit_project_path(project)
					fill_in "existing_resources", with: existing_resource_id
					click_on "add_existing_resource"		
				end

				it "should add the form to the page" do
					title_input = page.find(:css, %{[name^="project[resources_attributes]"][name$="[title]"]})
					title_input.value.should eql("Existing Resource")
				end
				
				describe "and clicking save" do
					before do
						find(:css, %{[name^="project[resources_attributes]"][name$="[title]"]}).set("NEW CHINESE NEWSPAPER")
						click_save
					end

					it {should have_content("NEW CHINESE NEWSPAPER")}
				end

			end


		end

	end

end



				

