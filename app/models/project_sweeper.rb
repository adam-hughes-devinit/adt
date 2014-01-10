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

  # If our sweeper detects that a Project was saved call this
  def after_save(this)
    expire_cache_for(this)
  end
 
  def expire_cache_for(this)
    #p "Expiring cache for #{this.inspect}"

     # Gets projects from this.
    if this.respond_to? :project 
      projects = [this.project]
    elsif this.is_a? Project
      projects = [this]
    elsif this.respond_to? :projects
      projects = this.projects
    else
      projects = []
    end

    projects.each do |project|
      # expire the to_english method
      Rails.cache.delete("projects/#{project.id}/to_english/no_title")
      Rails.cache.delete("projects/#{project.id}/to_english/title")

      # expire the Show page(s) no that it is changed
      Rails.cache.delete("projects/#{project.id}/signed_in/aiddata")
      Rails.cache.delete("projects/#{project.id}/signed_in/non_aiddata")
      Rails.cache.delete("projects/#{project.id}/not_signed_in/non_aiddata")

      # expire the Search Results now that it is changed
      Rails.cache.delete("projects/#{project.id}/search_result/aiddata")
      Rails.cache.delete("projects/#{project.id}/search_result/non_aiddata")
      # Expire the index page(s) now that a project has changed
      # expire_action action: :index 

      # expire cache of Search results
      Rails.cache.delete("projects/faceted")
      # expire /recent
      Rails.cache.delete("recent")
      # expire the CSV text
      project.expire_csv_text
      project.expire_xml
    end

  end



end
