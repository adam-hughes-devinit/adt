require 'spec_helper'
include ProjectSpecHelper


describe 'Code pages', js: true do

	let(:aiddata) {Organization.find_or_create_by_name("AidData")}
	let(:aiddata_user) {FactoryGirl.create :user, owner: aiddata}
	let(:organization_type) {FactoryGirl.create :organization_type}

	subject {page}

	CODE_TYPES = [:organization, :currency, :crs_sector, :oda_like, :status, :flow_type, :verified]
	
	CODE_TYPES.each do |code_type|
		describe "#{code_type}" do
			let(:code) {FactoryGirl.create code_type}
			
			before do 
				sign_in_aiddata_user
			end
			
			describe "can be displayed" do
				before do
					visit polymorphic_path(code)
				end

				it {should have_content(code.name)}
			end

			describe "can be edited" do
				before do 
					visit edit_polymorphic_path(code)
					fill_in "Name", with: "New code name!"
					click_button "Save"
				end
				it {should have_content("New code name!")}
			end

			describe "can be created" do
				before do

					organization_type.save!

					visit new_polymorphic_path(code.class)
					fill_in "Name", with: "Another new code name!"
					
					if code.respond_to? :iso3
						fill_in "Iso3", with: "XYZ"
					end

					if code.respond_to? :organization_type
						select organization_type.name, from: "Organization type"
					end

					
					click_button "Save"
				end

				it {should have_content("Another new code name!")}

				describe "and then destroyed" do
					before do 
						click_on "Destroy"
						page.driver.browser.switch_to.alert.accept
					end

					it {should have_content("View all") }
				end


			end

		end


	end



end
