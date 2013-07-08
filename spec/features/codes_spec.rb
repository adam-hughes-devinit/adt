require 'spec_helper'
include ProjectSpecHelper

describe 'Code pages' do
	let(:aiddata) {Organization.find_or_create_by_name("AidData")}
	let(:aiddata_user) {FactoryGirl.create :user, owner: aiddata}

	subject {page}

	CODE_TYPES = [:currency, :crs_sector, :oda_like, :status, :flow_type, :verified]
	
	CODE_TYPES.each do |code_type|
		describe "#{code_type}" do
			let(:code) {FactoryGirl.create code_type}
			
			before do 
				sign_in_aiddata_user
			end
			
			describe "can be displayed" do
				before do
					visit url_for(code)
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
					visit new_polymorphic_path(code.class)
					fill_in "Name", with: "Another new code name!"
					if code.respond_to? :iso3
						fill_in "Iso3", with: "XYZ"
					end
					
					click_button "Save"
				end

				it {should have_content("Another new code name!")}

			end

		end


	end



end
