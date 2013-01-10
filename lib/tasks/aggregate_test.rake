namespace :aggregator do
	desc "Test aggregator"
	task :test => :environment do
	
		require 'open-uri'

		def get_aggregate_data(params_string)
			aggregate_url="http://localhost:3000/aggregates/projects"
			call_url = "#{aggregate_url}?#{params_string}"
			p "  --  --  AGG:: #{call_url}"
			JSON.parse(open(call_url){|f| f.read })
		end
	
		p "  --  Testing on localhost"
		

		p "  --  Test get=donor"	
		donor_data = get_aggregate_data "get=donor"

		donor_sum = 0
		donor_data.map{|d| donor_sum += d["usd_2009"]}

		real_donor_sum = 0
		Country.all.each{|c| c.projects_as_donor.each {|p| real_donor_sum += p.usd_2009.to_f if p.active }}
		
		if real_donor_sum.round == donor_sum.round
			p "PASS donor/sector"
		else 
			p "FAIL donor :: donor_sum: #{donor_sum} | Real value: #{real_donor_sum}"
		end
		
		
		def test_code(code_class, get_call, filter_name=get_call)
			p "  --  Test get=#{get_call}"
			code_api_data = get_aggregate_data "get=#{get_call}&#{filter_name}=#{
			code_class.all.map { |c| "#{CGI::escape(c.name)}"}.join "*"}"
			
			code_api_sum = 0
			code_api_data.map{|d| code_api_sum += d["usd_2009"]}
			
			real_sum = 0
			code_class.all.each {|s| s.projects.each {|p| real_sum += p.usd_2009.to_f if p.active}}
			
			if code_api_sum.round == real_sum.round
				p "PASS #{get_call}"
			else 
				p "FAIL #{get_call} :: API value: #{code_api_sum} | Real value: #{real_sum}"
			end
		end
		
		test_code(Sector, "sector_name")
		test_code(OdaLike, "flow_class")



	end
end
