module SearchHelper
	include AggregatesHelper
	
	# Constants in an initializer

	def custom_search(options = {})
	  options.reverse_merge! paginate: true
 	  options.reverse_merge! default_to_official_finance: true

	  @search = Project.search do
	  	
	  	# Default to official finance if the user is coming from somewhere else
	  	if (options[:default_to_official_finance]==true) && # if defaulting is enabled
	  		!(request.env['HTTP_REFERER'] =~ /projects/) && # and it's coming from somewhere other than /projects/
	  		!current_user_is_aiddata # and the current_user isn't AidData
	  		
	  		if (params.keys.select {|k| (k.to_s =~ /name/) }.length == 0)
		  		@scope = Scope.find_by_symbol("official_finance")
		  		params[:scope] = @scope.symbol
		  	end
	  	end
	  	
	    # Text search
	    fulltext params[:search]
	    
	    # Filter by params
	    (FACETS + WORKFLOW_FACETS).each do |f|
	        facet f[:sym]
	        if requested_values = params[f[:sym]]
	        	if requested_values.class == String
		        	# VALUE DELIMITER defined in Aggregates helper
		        	requested_values = requested_values.split(VALUE_DELIMITER) 
		        end
		        with f[:sym], requested_values
	        end			      
	    end

	    # order
	  	order_by((params[:order_by] ? params[:order_by].to_sym : :title),
	  		params[:dir] ? params[:dir].to_sym : :asc )
	    
	    # pagination
	    if options[:paginate]==true
	      paginate :page => params[:page] || 1, :per_page => params[:max] || 50
	    else 
	    	# There's some destructive interference between sunspot and will_paginate.
	    	# If you don't specify pagination here, will_paginate overrides it with
	    	# per_page: 30, which sucks.
	    	paginate page: 1, per_page: 10**6
	    end

	  end
	  
	  @search.results
	end


end
