class ProjectSweeper < ActionController::Caching::Sweeper
  observe Project # This sweeper is going to keep an eye on the Project model
 
  # If our sweeper detects that a Project was created call this
  def after_create(project)
    expire_cache_for(project)
  end
 
  # If our sweeper detects that a Project was updated call this
  def after_update(project)
    expire_cache_for(project)
  end
 
  # If our sweeper detects that a Project was deleted call this
  def after_destroy(project)
    expire_cache_for(project)
  end
 
  private
  def expire_cache_for(project)
    # expire the Show page(s) no that it is changed
    expire_fragment(%r{projects/#{project.id}.*})
    # Expire the index page now that a project has changed
    expire_fragment(%r{.*index.*}) 
    # expire the CSV text
    project.expire_csv_text
  end
end
