class ProjectSweeper < ActionController::Caching::Sweeper
  observe Project, Flag, Comment # This sweeper is going to keep an eye on the Project model
 
  # If our sweeper detects that a Project was created call this
  def after_create(this)
    expire_cache_for(this)
  end
 
  # If our sweeper detects that a Project was updated call this
  def after_update(this)
    expire_cache_for(this)
  end
 
  # If our sweeper detects that a Project was deleted call this
  def after_destroy(this)
    expire_cache_for(this)
  end
 
  def expire_cache_for(this)
    #p "Expiring cache for #{this.inspect}"

    if this.respond_to? :project 
      project = this.project
    elsif this.is_a? Project
      project = this
    else
      project = nil
    end

    if project
      # expire the Show page(s) no that it is changed
      expire_fragment("projects/#{project.id}/signed_in/aiddata")
      expire_fragment("projects/#{project.id}/signed_in/non_aiddata")
      expire_fragment("projects/#{project.id}/not_signed_in/non_aiddata")

      # expire the Search Results now that it is changed
      expire_fragment("projects/#{project.id}/search_result/aiddata")
      expire_fragment("projects/#{project.id}/search_result/non_aiddata")
      # Expire the index page(s) now that a project has changed
      # expire_action action: :index 

      # expire cache of Search results
      Rails.cache.delete("projects/faceted")
      # expire /recent
      expire_fragment("recent")
      # expire the CSV text
      project.expire_csv_text
    end

  end



end
