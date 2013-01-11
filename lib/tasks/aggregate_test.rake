namespace :aggregator do
	desc "Test aggregator"
	task :test => :environment do
	
		require 'open-uri'
		require 'net/http'
		
		@passes = 0
		@fails = 0
		def get_aggregate_data(params_string)
			aggregate_url="http://localhost:3000/aggregates/projects"
			call_url = "#{aggregate_url}?#{params_string}"
			JSON.parse(open(call_url){|f| f.read })
		end
		
		def post_aggregate_data(params_hash)
			aggregate_url= "http://localhost:3000/aggregates/projects"
			res = Net::HTTP.post_form(URI(aggregate_url), params_hash)
			JSON.parse(res.body)
		end
		
		# Begin
		p " Testing on localhost"
		
		# donor
		p " Test get=donor"	
		donor_data = get_aggregate_data "get=donor"

		donor_sum = 0
		donor_data.map{|d| donor_sum += d["usd_2009"]}

		real_donor_sum = 0
		Country.all.each{|c| c.projects_as_donor.each {|p| real_donor_sum += p.usd_2009.to_f if p.active }}
		
		if real_donor_sum.round == donor_sum.round
			p "      PASS donor"
			@passes +=1
		else 
			p "      FAIL donor :: donor_sum: #{donor_sum} | Real value: #{real_donor_sum}"
			@fails +=1
		end

		# function
		def test_code(code_class, get_call, filter_name=get_call)
			p "Test #{get_call}"
				code_api_data = get_aggregate_data "get=#{get_call}&#{filter_name}=#{
				code_class.all.map { |c| "#{CGI::escape(c.name)}"}.join "*"}"
			
				code_api_sum = 0
				code_api_data.map{|d| code_api_sum += d["usd_2009"].to_f}
			
				real_sum = 0
				code_class.all.each {|s| s.projects.each {|p| real_sum += p.usd_2009.to_f if p.active}}
			
				if code_api_sum.round == real_sum.round
					p "     PASS all #{get_call} by string"
					@passes+=1
				else 
					p "     FAIL all #{get_call} by string :: API value: #{code_api_sum.round} | Real value: #{real_sum.round}"
					@fails+=1
				end
				
				params_hash = { "get"=> "#{get_call}", "#{filter_name}[]"=> (code_class.all.map { |c| "#{CGI::escape(c.name)}"}) }
				post_code_api_data = post_aggregate_data params_hash
			
				post_code_api_sum = 0
				post_code_api_data.map{|d| post_code_api_sum += d["usd_2009"].to_f}
			

				if post_code_api_sum.round == real_sum.round
					p "     PASS all #{get_call} by array"
					@passes+=1
				else 
					p "     FAIL all #{get_call} by array :: API value: #{post_code_api_sum.round} | Real value: #{real_sum.round}"
					p "         Params: #{params_hash.inspect}"
					@fails+=1
					raise "Check the server"
				end
								
			p "    Testing Values"
			
				code_class.all.each do |code| 
				
					single_code_api_data = get_aggregate_data "get=#{get_call}&#{filter_name}=#{CGI::escape code.name}"
					single_code_api_sum = 0
					single_code_api_data.map{|d| single_code_api_sum += d["usd_2009"].to_f}
				
					single_code_real_sum = 0
					code.projects.each {|p| single_code_real_sum += p.usd_2009.to_f if p.active}
				
					if single_code_api_sum.round == single_code_real_sum.round
						p "        PASS #{code.name}"
						@passes +=1
					else
						p "        FAIL #{code.name} :: API value: #{single_code_api_sum.round} | Real value: #{single_code_real_sum.round}"
						@fails+=1
						
					end
				end	
			p "     Testing Combinations"
				7.times do 
					possible_getters = ["year", "recipient_iso2", "recipient_iso3", "recipient_name", "donor", 
						"sector_name", "flow_class", "status"]
						
					get_set = possible_getters.sample(rand(3).round+2)
					
					test_set = []
					
					(rand(3).round+2).times do 
						test_set.push(code_class.all.sample.name)
					end
										
					
					get_data = get_aggregate_data "get=#{get_set.map { |n| CGI::escape(n) }.join","}&#{filter_name}=#{test_set.map { |n| CGI::escape(n) }.join"*"}"
					params = { "get"=> "#{get_set.join","}", "#{filter_name}[]" => test_set.map { |n| CGI::escape(n) } }
					post_data = post_aggregate_data params
					
					real_sum = 0
					code_class.all.each do |s| 
						if test_set.include? s.name 
							s.projects.each {|p| real_sum += p.usd_2009.to_f if p.active}
						end
					end
			
					get_sum = 0
					get_data.each { |d| get_sum += d["usd_2009"].to_f}

					post_sum = 0
					post_data.each { |d| post_sum += d["usd_2009"].to_f}
			
					if post_sum.round == real_sum.round && get_sum.round == real_sum.round
						p "        PASS #{test_set.join(",")[0..25]}... "
						@passes+=1
					else
						p "        FAIL #{test_set.join "," } with #{get_set.join","} :: GET : #{get_sum.round} | POST : #{post_sum.round} | REAL : #{real_sum.round}"
						@fails +=1
					end
				end
		end
		
		
		# Test codes 
		test_code(Sector, "sector_name")
		test_code(OdaLike, "flow_class")
		test_code(Status, "status")	
		
		# Test years
		p "Test years"
		years = (2000..2010).to_a
		p "      Test all years"
		get_year = get_aggregate_data "get=year&year=#{years.join "*" }"
		params = {"get"=> "year", "year[]"=>years}
		post_year = post_aggregate_data params
		
		real_sum = 0
		Project.where("year in (?)", years).each {|p| real_sum += p.usd_2009.to_f if p.active }
		
		get_sum = 0
		get_year.each { |d| get_sum += d["usd_2009"].to_f}

		post_sum = 0
		post_year.each { |d| post_sum += d["usd_2009"].to_f}
		
		if post_sum.round == real_sum.round && get_sum.round == real_sum.round
			p "          PASS all years"
			@passes+=1
		else
			p "          FAIL all years :: GET : #{get_sum.round} | POST : #{post_sum.round} | REAL : #{real_sum.round}"
			@fails +=1
		end
		
		years.each do |y|
			get_year = get_aggregate_data "get=year&year=#{y}"
			params = { "get"=> "year", "year"=> "#{y}" }
			post_year = post_aggregate_data params
			
			real_sum = 0
			Project.where("year = #{y}").each { |p| real_sum += (p.usd_2009 || 0) if p.active }
			
			get_sum = 0
			get_year.each { |d| get_sum += d["usd_2009"].to_f}

			post_sum = 0
			post_year.each { |d| post_sum += d["usd_2009"].to_f}
			
			if post_sum.round == real_sum.round && get_sum.round == real_sum.round
				p "          PASS #{y}"
				@passes+=1
			else
				p "          FAIL #{y} :: GET : #{get_sum.round} | POST : #{post_sum.round} | REAL : #{real_sum.round}"
				@fails +=1
			end
		end
		
		##
		##
		## TO ADD: Random combinations
		##
		##
		
		p "------------------------------------------------------"
		p "   passes: #{@passes}"
		p "   fails: #{@fails}"
		end
end
