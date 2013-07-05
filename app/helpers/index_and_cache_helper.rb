module IndexAndCacheHelper

	# #######
	# Caching has been removed, but the name has been kept
	# as to not break things.
	# #######
	def recache_and_reindex_projects
	 	# p "Recache and reindex projects at #{Time.new}"
		
	 	reindex_projects

	end
	# handle_asynchronously :recache_and_reindex_projects

	def reindex_projects(projects)
		# p "Reindex projects at #{Time.new}"
		Sunspot.index!(projects || Project.all)
		# Sunspot.commit
	end
	# handle_asynchronously :reindex_projects



	def remake_files
	  all_projects = Project.all
    unless all_projects.empty?
      all_projects.sample.cache_files #sending no scope should remake all
    end
 		#Project.all.sample.cache_files # sending no scope should remake all
	end
	
	# handle_asynchronously :remake_files
	

  def reindex_and_recache_by_associated_object(object)
    # What's the best way to background this?
    if object.respond_to? 'projects'
      reindex_projects(object.projects)
      remake_files	
    end	
  end

end
