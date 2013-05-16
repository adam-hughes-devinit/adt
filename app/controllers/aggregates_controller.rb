class AggregatesController < ApplicationController
include AggregatesHelper
	skip_before_filter :signed_in_user  
	def projects
		require 'open-uri'
		
		@recipient_field_names = ["name", "iso2", "iso3"]
		# Use "XR" for Africa, regional's ISO2
		def	africa_regional_iso2(fn)
			 if fn == 'iso2' 
			 	"'XR'" 
			 else
			 	"'Africa, regional'"
			 end
		end


		
		@duplication_scheme = DUPLICATION_HANDLERS.select { |h| h[:external] == "#{params[:multiple_recipients]}" }[0] || DUPLICATION_HANDLERS[0] 
		
		@fields_to_get = []
		@get = ["donor"] #overwritten if params provided in request

		if params[:get].class == String
			@get = params[:get].split(",")
		elsif params[:get].class == Array
			@get = params[:get]
		end
		
		#  &wdi=#{wdi_code} 

		if @get && @get.include?("year") && @get.include?("recipient_iso3")
			if params[:wdi].class== String
				@wdi = params[:wdi].split(VALUE_DELIMITER)
			elsif params[:wdi].class== Array
				@wdi = params[:wdi]
			else 
				@wdi = []
			end
			@wdi = @wdi.map do |wdi_input| 
				if wdi_input.upcase == wdi_input.upcase[/[A-Z0-9\.]+/]
					wdi_input.upcase
				end 
			end
		end

		VALID_FIELDS.each do |field|
	      	if @get.include?(field[:external]) 
	      		@fields_to_get.push field
	      		@sorter = field[:sorter]
	      	end
	 end

	    @filters = ["active = 't' "]

			# defined in AggregateHelper
	  WHERE_FILTERS.each do |wf|
	    	param_values = params[wf[:sym]] 
		    if param_values		    	
		    	if param_values.class == String 
		    		param_values = param_values.split(VALUE_DELIMITER)
		    	else 
		    		param_values = param_values.map { |v| URI::decode( v.gsub(/\+/, ' ')) }
		    	end

		    	if valid_values = (wf[:options] && param_values)
		    		@filters.push "#{wf[:internal_filter]} in ('#{valid_values.join("','")}')"
		    	end
		    end
		end
		
			


	    if !@fields_to_get.blank?  	
		    
		    # ---------- I really tried to do it right, but couldn't get it! --------------
		    #
		    # @data = Project.find( :all,
		    # 	select: "usd_defl as usd_2009, #{@fields_to_get.map{|f| f[:internal] + ' as ' + f[:external]}.join(', ')}",
		    # 	group: "#{@fields_to_get.map{|f| f[:internal]}.join(', ')}",
		    # 	conditions: "active = 't'",
		    # 	joins: ["INNER JOIN countries donors ON donors.id = projects.donor_id ", 
		    # 			:transactions, :geopoliticals, :sector],
		    # 	limit: 100,
		    # 	order: nil 
		    # 	    	)

		 	sql = "select #{@duplication_scheme[:amounts]}, count(*) as count,"+
		 			" #{@fields_to_get.map{|f| f[:internal] + ' as ' + f[:external]}.join(', ')}"+
		 			" from (select projects.*, "+
		 					" #{eval(@duplication_scheme[:select])}"+
		 					" from projects "+
							" #{@duplication_scheme[:join]}"+
				 			" #{@duplication_scheme[:group]}" +
				 			") p \n"+
				 		
				 		" LEFT OUTER JOIN (select id, project_id, oda_like_1_id, oda_like_2_id, oda_like_master_id, "+
				 		" (case when oda_like_master_id is not null then oda_like_master_id when oda_like_2_id is not null then oda_like_2_id else oda_like_1_id end) oda_like_best_id from flow_classes)" +
				 		" modified_flow_classes on p.id = modified_flow_classes.project_id " +
				 		
				 		" LEFT OUTER JOIN oda_likes on modified_flow_classes.oda_like_best_id = oda_likes.id	"+
				 		
		 				"LEFT OUTER JOIN crs_sectors on p.crs_sector_id = crs_sectors.id
		 				LEFT OUTER JOIN flow_types on p.flow_type_id = flow_types.id
		 				LEFT OUTER JOIN verifieds on p.verified_id = verifieds.id
		 				LEFT OUTER JOIN statuses on p.status_id = statuses.id
		 				LEFT OUTER JOIN intents on p.intent_id = intents.id		 				

			 			INNER JOIN countries donors on p.donor_id = donors.id 
			 			LEFT OUTER JOIN (select sum(usd_current) as sum_usd_current, sum(usd_defl) as sum_usd_defl, project_id from transactions group by project_id) as t on p.id = t.project_id
			 		where 
			 		#{@filters.join(' and ').gsub(/(\w)'(\w)/, '\1\'\'\2')}
					group by #{@fields_to_get.select{|f| Rails.env.production? || Rails.env.development? ? f[:internal] : f[:group] }
						.map{|f| Rails.env.production?  || Rails.env.development? ? f[:internal] : f[:group]}.join(', ')} 
					order by #{@sorter}"
					
					# That little nonsense is because you group by recipient_iso2 in SQLite but recipients.name in PSQL
			@data = ActiveRecord::Base.connection.execute(sql)


			# HANDLING WDI
			if @wdi  # && @data.last["year"] && @data.last["recipient_iso3"]
				p "Trying"
				active_recipients = @data.map {|d| d["recipient_iso3"] }
				wdi_recipient_year_nest = {}
				
				active_recipients.each do |recipient_iso3|
					if recipient_iso3.length == 3
						wdi_recipient_year_nest[recipient_iso3]={} 
				
						("2000".."2012").each do |y|
							wdi_recipient_year_nest[recipient_iso3][y] = {}
						end
				
						@wdi.each do |wdi_code|
				
							request_url = "http://api.worldbank.org/countries/#{recipient_iso3}/indicators/#{wdi_code}?per_page=50&format=json&date=2000:2012"
							wdi_response_string = open(request_url){|io| io.read} 
							response_feed = ActiveSupport::JSON.decode(wdi_response_string)
							# go through for each year and drop it in "nest"
							response_feed[1].each do |wdi_point|
								# then drop it by _nest[recipient][year]
								wdi_recipient_year_nest[recipient_iso3][wdi_point["date"]][wdi_point["indicator"]["id"]] = wdi_point["value"]
							end
						end
					end
				end
				p wdi_recipient_year_nest.inspect
				p @wdi.inspect
				if wdi_recipient_year_nest
					@data.each do |d|
						if wdi_values = wdi_recipient_year_nest[d["recipient_iso3"]] 
							if wdi_values_iso3_year = wdi_values[d["year"].to_s]
								wdi_values_iso3_year.each_pair do |k,v|
									d[k] = v
								end
							end
						end
					end
				end
			end
		
				
			
			
			@column_names = @fields_to_get.map{|f| f[:external]} + ["usd_2009", "usd_current", "count"] + (@wdi || [])
		  p @column_names
		  
		  respond_to do |format|
		    # default: render json
		    format.json { render json: @data.as_json(only: @column_names)}
		    # if asking for CSV, send an on-the-fly CSV
		    format.csv { send_data data_to_csv, filename: "AidData_China_Aggregates_#{Time.now.strftime("%y-%m-%d-%H:%M:%S.%L")}.csv"}
		  end
		  p @column_names
		else	
			render json: params
	  end  		
	
	end
	
	private
		def data_to_csv
		 CSV.generate do |csv|
				csv << @column_names
				@data.each do |datum|
					csv << datum.values_at(*@column_names)
				end
			end
		end
end
