class Scope < ActiveRecord::Base
	include IndexAndCacheHelper
	include ScopesHelper

	attr_accessible :description, :name, :symbol,
	:scope_channels, :scope_channels_attributes

	after_save :remake_scopes_hash
	after_destroy :remake_scopes_hash

	after_save :touch_projects
	after_destroy :touch_projects
	
	


	def channels
		scope_channels.map { |c| c.filters }
	end

	def to_query_params(project_or_aggregate, allow_many_channels=false)
		param_array = scope_channels.map do |channel|

			channel_string = ""

			channel.scope_filters.each do |filter|
				
					if project_or_aggregate == "aggregate"
						channel_string += filter.to_aggregate_query_params
					else 
						channel_string += filter.to_aggregate_query_params
					end

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

	has_many :scope_channels, dependent: :destroy
	accepts_nested_attributes_for :scope_channels, allow_destroy: true 

	validates :name, presence: true, uniqueness: true
	validates :symbol, presence: true, uniqueness: true,
		format: { with: /^[a-z\_]+$/,
				 message: "Use only lowercase letters and underscores." }
	


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

		# Use the cached version if possible.
		#  (scopes_hash will recache itself if needed)
 		this_scope_hash = scopes_hash.select { |s| s["name"] == self.name }[0]

        passes = false # set to true if project fits the scope

        # It only has to pass 1 channel 
		this_scope_hash[:channels].each do |channel|

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



	def build_scope_scaffold
			#fills out a skeleton, returns self
		self.name = 'Scope Name'
		self.symbol = 'scope_symbol'
		self.description = 'This is the description of the scope.'
		self.scope_channels.build
		self.scope_channels.each do |c|
			c.build_scope_channel_scaffold
		end

		self
	end

	def as_json(options={})
		super(
			only: [:id,:name, :symbol, :description], 
			methods: [:channels]
		) 
	end


	def touch_projects
		start = Time.new

		p "Touch projects for #{self.name} at #{start}"
	 	
		Project.all.each{ |p| p.delay.save }

	 	# recache files
	 	p "Start remaking the Scope files after #{ (Time.new - start).round(2) } seconds"

	 	Project.first.cache_files

	 	p "Finished after #{ (Time.new - start).round(2) } seconds"

	end
	

	

end
