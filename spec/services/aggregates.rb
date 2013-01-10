require 'spec_helper'
require 'open-uri'

describe "Aggregate API" do
	it "returns the right sum by donor" do
		api_data = open(aggregate_api_url+"?get=donor")
		json_data = JSON.parse(api_data)
		
		
		db_data = {}
		
		Country.all.each { |c| c.projects_as_donor.each { |p| db.data[c.name] += p.usd_2009 } }
		
		p db_data
		
		5.should eq(5)
	end
	
end
