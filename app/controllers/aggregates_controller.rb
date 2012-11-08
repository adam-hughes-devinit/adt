class AggregatesController < ApplicationController
	skip_before_filter :signed_in_user  
	def projects
		@valid_fields = [
			{external: "donor", internal: "donors.iso3", group: "donors.iso3"},
			{external: "year",  internal: "year", group: "year"},
			{external: "sector_name", internal: "(case when sectors.name is null then 'Unset' else sectors.name end)", group: "sectors.name"},
			{external: "recipient_name",   group: "recipient_name", internal: "recipient_name"},
			{external: "recipient_iso2",   group: "recipient_iso2", internal: "recipient_iso2"},
			{external: "recipient_iso3",   group: "recipient_iso3", internal: "recipient_iso3"},
			{external: "flow_class", group: "oda_likes.name", internal: "(case when oda_likes.name is null then 'Unset' else oda_likes.name end)"}
			# oda -like

			# active 

		]
		@fields_to_get = []

		if params[:get].class == String
			@get = params[:get].split(",")
		elsif params[:get].class == Array
			@get = params[:get]
		end
			

		@valid_fields.each do |field|
	      	if @get.include?(field[:external]) 
	      		@fields_to_get.push field
	      	end
	    end

	    where_filters = [
	    	{sym: :recipient_iso2, options: Country.all.map{|c| c.iso2} , internal_filter: "recipient_iso2"},
	    	{sym: :sector_name, options:Sector.all.map{|c| c.name} , internal_filter: "sectors.name"},
	    	{sym: :verified, options: Verified.all.map{|c| c.name} , internal_filter: "verifieds.name"},
	    	{sym: :flow_type, options: FlowType.all.map{|c| c.name} , internal_filter: "flow_types.name"},
	    	{sym: :flow_class, options: OdaLike.all.map{|o| o.name}, internal_filter: "oda_likes.name" }
	    ]

	    @filters = ["active = 't' "]

	    where_filters.each do |wf|
	    	param_values = params[wf[:sym]] 
		    if param_values
		    	if param_values.class == String
		    		param_values = param_values.split(',')
		    	end

		    	if valid_values = (wf[:options] & param_values)
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

		 	sql = "select sum(usd_defl) as usd_2009, sum(usd_current) as usd_current, #{@fields_to_get.map{|f| f[:internal] + ' as ' + f[:external]}.join(', ')}
		 			from (select projects.*,
		 					(case when count(recipients.id) > 1 then 'Africa, regional' else max(recipients.name) end) as recipient_name,
		 					(case when count(recipients.id) > 1 then 'Africa, regional' else max(recipients.iso2) end) as recipient_iso2,
		 					(case when count(recipients.id) > 1 then 'Africa, regional' else max(recipients.iso3) end) as recipient_iso3
		 					from projects 
			 				INNER JOIN geopoliticals on projects.id = geopoliticals.project_id 
				 			INNER JOIN countries recipients on geopoliticals.recipient_id = recipients.id
				 			group by projects.id
				 			) p
				 			
		 				LEFT OUTER JOIN sectors on p.sector_id = sectors.id
		 				LEFT OUTER JOIN oda_likes on p.oda_like_id = oda_likes.id
		 				LEFT OUTER JOIN flow_types on p.flow_type_id = flow_types.id
		 				LEFT OUTER JOIN verifieds on p.verified_id = verifieds.id

			 			INNER JOIN countries donors on p.donor_id = donors.id 
			 			INNER JOIN transactions on p.id = transactions.project_id
			 		where 
			 		#{@filters.join(' and ')}
					group by #{@fields_to_get.select{|f| Rails.env.production? ? f[:internal] : f[:group] }.map{|f| Rails.env.production? ? f[:internal] : f[:group]}.join(', ')} "
					
					# That little nonsense is because you group by recipient_iso2 in SQLite but recipients.name in PSQL
			@data = ActiveRecord::Base.connection.execute(sql)
			
		    render json: @data.as_json(
		    	only: ["usd_2009", "usd_current"] +  @fields_to_get.map{|f| f[:external]}
		    	)
		else	
			render json: params
	    end  		
	
	end
end