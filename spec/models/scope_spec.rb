require 'spec_helper'

describe Scope do
	let(:scope){FactoryGirl.create(:scope)}
	let(:cancelled) {FactoryGirl.create(:status, name: "Cancelled")}
	let(:passing_project){FactoryGirl.create(:project, status: cancelled, year: 2009)}
	let(:failing_project){FactoryGirl.create(:project, status: cancelled, year: 2001)}
	let(:other_failing_project){FactoryGirl.create(:project, status: FactoryGirl.create(:status, name: "Pipeline"))}

	subject {scope}

	describe "should have a valid factory" do
		it {should be_valid}
	end


	describe "should allow passing projects" do

		subject {passing_project}
		its(:scopes) {should include(scope)}
		its(:scope_names) {should include(scope.name)}

	end

	describe "should not allow failing projects" do
		
		subject {failing_project}
		its(:scopes) {should_not include(scope)}
		subject {other_failing_project}
		its(:scopes) {should_not include(scope)}

	end

	describe "should spit out query strings" do


		describe "for the project API" do

			it {should respond_to(:to_project_query_params)}
			its(:to_project_query_params){should match(/status_name/)}
			its(:to_project_query_params){should match(/Cancelled/)}
			its(:to_project_query_params){should match(/2009/)}
			its(:to_project_query_params){should match(/2010/)}
		end

		describe "for the Aggregate API" do

			it {should respond_to(:to_aggregate_query_params)}

			its(:to_aggregate_query_params) {should match(/status/)}
			its(:to_aggregate_query_params) {should match(/Cancelled/)}

			its(:to_aggregate_query_params) {should match(/year/)}
			its(:to_aggregate_query_params) {should match(/2010/)}
			its(:to_aggregate_query_params) {should match(/2009/)}
		end

	end

end
