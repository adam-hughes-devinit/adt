module IndexAndCacheHelper

	def recache_and_reindex_projects
		
		Project.each{ |p| Project.cache! now: true, include_files: false }
		
		Sunspot.reindex(Project.all)
		
		Scope.all.each do |s|
			Project.all.sample.cache_files(s.symbol.to_sym)
		end

	end
	handle_asynchronously :recache_and_reindex_projects

end
