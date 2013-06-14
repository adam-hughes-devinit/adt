module ScopeIncludesProject
	def includes_project?(project)
		# 1) Make sure scope is valid 
			# This is done at the scope_filter 
			# and scope_filter_value level
		
		# 2) For each channel,
			# 2.1) For each parameter,
				# 2.1.1) Does the project have one of these values?
				#   -- if array, use include
				#   if no, then kick it to the next channel
				#   if yes, then continue
				# 2.1.2) If project matches parameters, 
				#   include the scope and move on

        passes = false # set to true if project fits the scope

        # It only has to pass 1 channel 
		channels.each do |channel|

			passes_this_channel = true # set to false if not included below

			channel.each do |filter|
				
				
				# if [value1, value2] doesn't include project.field,
				# then the project doesn't fit!
				value_for_this_project = project.send(filter[:field]) 

				# For example, country_name returns an array. 
				if value_for_this_project.class != Array
					values_for_this_project = [value_for_this_project]
				else 
					values_for_this_project = value_for_this_project
				end


				# ScopeFilter does this itself, but since I'm using the hash, I have to redo it.
				required_values =   filter[:values].select { |v| v !~ /^not/}
				disallowed_values =  filter[:values].select { |v| v =~ /^not/}.map{ |v| v.gsub(/^not\s/, '')}

				values_for_this_project.each do |this_value|
					if ( 
							(	!required_values.blank? && # if required values exist AND 
								!required_values.include?(this_value) # don't include the value for this project
							) || 
							
							(	!disallowed_values.blank? && # or disallowed values exist 
								disallowed_values.include?(this_value) # AND _do_ include value for this project
							)
						)
						# it doesn't pass this channel.
						passes_this_channel = false
					else
						# Lets say the scope wants recipient_iso3 = "RWA",
						# and the project has 2 recipients: "RWA" and "BDI".
						# It _should_ match, since the project was in Rwanda.
						#
						# hence, if it passes once, it passes the whole thing.
						break
					end
				end

				# if it didn't pass the filter, you might as well
				# start trying the next channel (if there is one)
				break if !passes_this_channel
			
			end
			# if it made it this far, it passed 1 whole channel
			if passes_this_channel == true
				passes = true
				break
			end

		end

		return passes
	end

end