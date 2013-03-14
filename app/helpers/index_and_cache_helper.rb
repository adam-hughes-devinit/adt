module IndexAndCacheHelper

	def recache_and_reindex_projects
	 	p "Recache and reindex projects at #{Time.new}"
		
	 	reindex_projects
	 	recache_projects
	end
	# handle_asynchronously :recache_and_reindex_projects

	def reindex_projects(projects)
		p "Reindex projects at #{Time.new}"
		Sunspot.index(projects || Project.all)
		Sunspot.commit
	end
	handle_asynchronously :reindex_projects

	def recache_projects(projects)
		p "Recache projects at #{Time.new}"
		projects = projects || Project.all
		projects.each{ |p| p.cache! now: true, include_files: false }
	end
	handle_asynchronously :recache_projects

	def remake_files
		Scope.all.each do |s|
	 		p "Caching #{s.symbol.to_sym} #{Time.new}"
	 		Project.all.sample.cache_files(s.symbol.to_sym)
	 	end
	end
	handle_asynchronously :remake_files
	

	def reindex_and_recache_by_associated_object(object)
  		# What's the best way to background this?
      if object.respond_to? 'projects'
	  		reindex_projects(object.projects)
			recache_projects object.projects
			remake_files	
	  end	
  	end

end
