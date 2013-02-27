module IndexAndCacheHelper

	def recache_and_reindex_projects
		
		Project.all.each{ |p| p.cache! now: true, include_files: false }
		
		Sunspot.index!(Project.all)
		
		Scope.all.each do |s|
			p "Caching #{s.symbol.to_sym} #{Time.new}"
			Project.all.sample.cache_files(s.symbol.to_sym)
		end

	end
	handle_asynchronously :recache_and_reindex_projects

end
