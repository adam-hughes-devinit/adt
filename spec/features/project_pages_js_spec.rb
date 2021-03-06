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
					first(:css, %{[name^="project[resources_attributes]"][name$="[title]"]}).set("CHINESE NEWSPAPER")
					first(:css, %{[name^="project[resources_attributes]"][name$="[source_url]"]}).set("www.china.com")
					resource_type_input = first :css, %{[name^="project[resources_attributes]"][name$="[resource_type]"]}
					within resource_type_input  do
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
				
				# it "should have a form for the resource" do
				# 	title_input = page.first(:css, %{[name^="project[resources_attributes]"][name$="[title]"]})
				# 	title_input.value.should eql("Existing Resource")
				# end	

				it {should have_field(
					"project_resources_attributes_0_title",  # 0 is the projects index
					with: existing_resource.title
				)}

				describe "and clicking save" do
					before do
						first(:css, %{[name^="project[resources_attributes]"][name$="[title]"]}).set("NEW CHINESE NEWSPAPER")
						click_save
					end

					it {should have_content("NEW CHINESE NEWSPAPER")}
				end

			end

			describe "by attaching existing ones" do
				before do
					existing_resource.save!
					existing_resource_id = existing_resource.id
					# visit resource_path(existing_resource)
					visit edit_project_path(project)
					fill_in "existing_resources", with: "#{existing_resource.id} "
					find("#add_existing_resource").click

				end

				it {should have_selector("#project_resources_attributes_#{existing_resource.id}_title")}

				describe "and clicking save" do
					before do
						first(:css, %{[name^="project[resources_attributes]"][name$="[title]"]}).set("NEW CHINESE NEWSPAPER")
						click_save
					end

					it {should have_content("NEW CHINESE NEWSPAPER")}
				end

			end


		end

	end

end



				

