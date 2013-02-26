class Scope < ActiveRecord::Base
	include IndexAndCacheHelper
	attr_accessible :description, :name, :symbol,
	:scope_channels, :scope_channels_attributes

	#after_initialize :build_scope_scaffold
	after_save :recache_and_reindex_projects


	def channels
		scope_channels.map { |c| c.filters }
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
				# 2.1.1) Does the project have one of these value?
				#   if no, then kick it to the next channel
				#   if yes, then continue
				# 2.1.2) If project matches parameters, 
				#   include the scope and move on
 

        passes = false # set to true if project fits the scope

        # It only has to pass 1 channel 
		self.scope_channels.each do |channel|

			passes_this_channel = true # set to false if not included below

			channel.scope_filters.each do |filter|
				
				
				# if [value1, value2] doesn't include project.field,
				# then the project doesn't fit!
				value_for_this_project = project.send(filter.field) 

				# Disallowed values begin with "not 

				if ( 
						(	!filter.required_values.blank? && # if required values exist AND 
							!filter.required_values.include?(value_for_this_project) # don't include the value for this project
						) || 
						
						(	!filter.disallowed_values.blank? && # or disallowed values exist 
							filter.disallowed_values.include?(value_for_this_project) # AND _do_ include value for this project
						)
					)
					# it doesn't pass this channel.
					passes_this_channel = false
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
end
