module ScopeToQueryParams
	
	def to_query_params(project_or_aggregate, allow_many_channels=false)
		param_array = channels.map do |channel|

			channel_string = ""

			channel.each do |filter|
					# The field name for this filter
					field = filter["field"]
					# now process the values:
					values = filter["values"]

					required_values = values.select { |v| v !~ /^not/}
					disallowed_values = values.select { |v| v =~ /^not/}.map{ |v| v.gsub(/^not\s/, '')}
					
					# add non-disallowed values to required_values
					if (dv = disallowed_values) && dv.length > 0
				      whole_dataset = Project.search do
				        (ProjectSearch::WORKFLOW_FACETS + ProjectSearch::FACETS).each do |f|
				          facet f[:sym]
				        end
				      end 

				      all_other_values = whole_dataset
				                .facet(field.to_sym)
				                .rows
				                .select {|r| !dv.include?(r.value) }
				                .map(&:value)
				      required_values += all_other_values
				    end

				    # Then build query string bits:
					if project_or_aggregate == "aggregate"
					    if field != 'active_string' &&
					      # Agg gives active by default
					      aggregate_query_name = AggregateValidators::WHERE_FILTERS
					        .select{|f| f[:sym] == field.to_sym || f[:search_constant_sym] == field.to_sym }[0][:sym].to_s

					      filter_string = "&#{aggregate_query_name}=#{required_values.join(AggregateValidators::VALUE_DELIMITER)}"
					    else
					    	filter_string = ""
					    end

					else 
					    filter_string = ""

					    required_values.each do |value|
					      filter_string += "&#{field}[]=#{value}"
					    end

					    
					end

					channel_string +=  filter_string.gsub(/\+/, "%2B")

			end

			channel_string
		end

		# Yikes, won't work
		if allow_many_channels
			param_array
		else
			param_array[0]
		end
	end

	def to_aggregate_query_params
		to_query_params("aggregate")
	end

	def to_project_query_params
		to_query_params("project")
	end
end
