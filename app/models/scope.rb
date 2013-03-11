class Scope < ActiveRecord::Base
	include IndexAndCacheHelper
	include ScopesHelper

	attr_accessible :description, :name, :symbol,
	:scope_channels, :scope_channels_attributes

	after_save :remake_scopes_hash
	after_save :recache_and_reindex_projects_for_this_scope
	
	after_destroy :remake_scopes_hash


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


	def recache_and_reindex_projects_for_this_scope
		start = Time.new

		p "Recache and reindex projects for #{self.name} at #{start}"
	#end

	# def dummy
	 	
		
	 	# reindex_projects_for_this_scope -- reindex ones that used to have this scope
	 	
	 	projects_which_had_this_scope = Project.search do
	 		with :scope, self.symbol
	 		# I hope I don't get screwed for doing it this way.
	 		paginate per_page: 10**5
	 	end.results

	 	p "Start reindexing #{projects_which_had_this_scope.count} projects that already have this scope after #{ (Time.new - start).round(2) } seconds"
	 	projects_which_had_this_scope.each do |p|
	 		Sunspot.index!(p)
	 		# committed below
	 	end

		
		# check other projects -- and reindex if they match this scope
		
		if projects_which_had_this_scope.blank?
			all_other_projects = Project.all
		else		
		 	all_other_projects = Project.where("id not in (?)", projects_which_had_this_scope.map(&:id))
		end

	 	p "Start reindexing #{all_other_projects.count } other projects after #{ (Time.new - start).round(2) } seconds"
	 	
	 	all_other_projects.each do |p|
	 		# This is only efficient bc Project#scope draws on the in-memory cache
	 		if p.scope.include? self.symbol.to_sym
	 			Sunspot.index!(p)
	 			# committed below
	 		end
	 		
	 	end
	 	p "Commit the reindexes after #{ (Time.new - start).round(2) } seconds"


		# recache_projects_for_this_scope
		
		Sunspot.commit
		
		projects_which_now_have_this_scope = Project.search do
	 		with :scope, self.symbol
	 		paginate per_page: 10**5
	 	end.results

	 	p "Start recaching #{projects_which_now_have_this_scope.count } projects with this scope after #{ (Time.new - start).round(2) } seconds"
	 	projects_which_now_have_this_scope.each do |p|
	 		p.cache! now: true, include_files: false
	 	end

	 	# recache files
	 	p "Start remaking the Scope files after #{ (Time.new - start).round(2) } seconds"
	 	Scope.all.each do |s|
	 		p "Starting cache task for  #{s.symbol.to_sym} #{Time.new}"
	 		Project.all.sample.cache_files(s.symbol.to_sym)
	 	end
	 	p "Finished after #{ (Time.new - start).round(2) } seconds"

	end
	handle_asynchronously :recache_and_reindex_projects_for_this_scope


	

end
