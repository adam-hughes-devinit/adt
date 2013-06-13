require 'spec_helper'

describe Resource do
	let(:resource) {FactoryGirl.create(:resource)}
	let(:other_resource) {FactoryGirl.create(:resource)}
	let(:project) {FactoryGirl.create(:project)}
	let(:other_project) {FactoryGirl.create(:project)}

	subject {resource}

	describe "have a valid Factory" do
		it { should be_valid}
	end

	describe "accepts projects" do
		before do 

			resource.projects << project
			resource.projects << other_project
		end	

		it {should be_valid}
	end

	describe "can be devour!ed" do
		before do 
			resource.projects << project
			resource.save!
			other_resource.projects << other_project
			other_resource.save!
			
			resource.devour! other_resource
		end

		its(:projects) {should include(other_project) }	
	end

	describe "can be fetched" do 
		it {should respond_to(:fetch!)}
		its(:fetch_without_delay!) {should be true}
	end
	

end
