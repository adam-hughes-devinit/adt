module SearchHelper
	
	# Constants definined in an initializer
	    
	def custom_search(options = {})
	  options.reverse_merge! paginate: true
 		options.reverse_merge! default_to_official_finance: true
	  @search = Project.search do
	  	
	  	if @scope = SCOPES.select { |s| s[:sym].to_s == params[:scope] }[0]
	  		nil
	  	elsif (options[:default_to_official_finance]) && !(request.env['HTTP_REFERER'] =~ /projects/)
	  		if (params.keys.select {|k| (k.to_s =~ /name/) }.length == 0)
		  		@scope = SCOPES.first
		  		params[:scope] = @scope[:sym].to_s
		  	end
	  	end
	  	
	    fulltext params[:search]
	    FACETS.each do |f|
	        facet f[:sym]
	        if params[f[:sym]].present?
	        	with f[:sym], params[f[:sym]] 
	        elsif @scope 
	        	if 	@scope[:with_and].keys.include?(f[:sym])
	        		with f[:sym], @scope[:with_and][f[:sym]]
	        	elsif @scope[:without].keys.include?(f[:sym])
	        		without f[:sym], @scope[:without][f[:sym]]
	        	end
	        end			      
	    end
	    
	    if @scope && @scope[:with_or]
	    	or_script = "any_of {" + @scope[:with_or].map {|w| "with(:#{w[0]}, '#{w[1]}'); "}.join(" ") +" }"
	    	eval or_script
	    end
	    	
	  	order_by((params[:order_by] ? params[:order_by].to_sym : :title), params[:dir] ? params[:dir].to_sym : :asc )
	    
	    if options[:paginate]==true
	      paginate :page => params[:page] || 1, :per_page => params[:max] || 50
	    end
	  end
	  
	  @projects = @search.results
	end

end
