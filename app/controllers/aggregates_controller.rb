class AggregatesController < ApplicationController
	skip_before_filter :signed_in_user  
	def projects
		@valid_fields = [
			{external: "donor", internal: "donors.iso3", group: "donors.iso3"},
			{external: "year",  internal: "year", group: "year"},
			{external: "sector_name", internal: "sectors.name", group: "sectors.name"},
			{external: "recipient_name",   group: "recipient_name", internal: "recipient_name"},
			{external: "recipient_iso2",   group: "recipient_iso2", internal: "recipient_iso2"},
			{external: "recipient_iso3",   group: "recipient_iso3", internal: "recipient_iso3"}
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

	    if params[:recipient_iso2] && params[:recipient_iso2].length==2
	    	@recipient_filter = "recipient_iso2='#{params[:recipient_iso2]}' and "
	    else 
	    	@recipient_filter=''
	    end

	    if !@fields_to_get.blank?  	
		    
		    # ---------- I really tried to do it right, but couldn't get it! --------------
		    # @data = Project.find( :all,
		    # 	select: "usd_defl as usd_2009, #{@fields_to_get.map{|f| f[:internal] + ' as ' + f[:external]}.join(', ')}",
		    # 	group: "#{@fields_to_get.map{|f| f[:internal]}.join(', ')}",
		    # 	conditions: "active = 't'",
		    # 	joins: ["INNER JOIN countries donors ON donors.id = projects.donor_id ", 
		    # 			:transactions, :geopoliticals, :sector],
		    # 	limit: 100,
		    # 	order: nil
		    # 	    	)

		 	sql = "select sum(usd_defl) as usd_2009, #{@fields_to_get.map{|f| f[:internal] + ' as ' + f[:external]}.join(', ')}
		 			from (select projects.*,
		 					(case when count(recipients.id) > 1 then 'Africa, regional' else recipients.name end) as recipient_name,
		 					(case when count(recipients.id) > 1 then 'Africa, regional' else recipients.iso2 end) as recipient_iso2,
		 					(case when count(recipients.id) > 1 then 'Africa, regional' else recipients.iso3 end) as recipient_iso3
		 					from projects 
			 				INNER JOIN geopoliticals on projects.id = geopoliticals.project_id 
				 			INNER JOIN countries recipients on geopoliticals.recipient_id = recipients.id
				 			group by projects.id
				 			) p
				 			
		 				INNER JOIN sectors on p.sector_id = sectors.id
			 			INNER JOIN countries donors on p.donor_id = donors.id 
			 			INNER JOIN transactions on p.id = transactions.project_id
			 		where 
			 		#{@recipient_filter}
			 		active='t'
					group by #{@fields_to_get.select{|f| f[:group] }.map{|f| f[:group]}.join(', ')} "
			
			@data = ActiveRecord::Base.connection.execute(sql)
			
		    render json: @data.as_json(
		    	only: ["usd_2009"] +  @fields_to_get.map{|f| f[:external]}
		    	)
		else	
			render json: params
	    end  		
	
	end
end