class ProjectSweeper < ActionController::Caching::Sweeper
  # This sweeper is going to keep an eye on the Project model
  include ProjectCache
  observe Project, Flag, Comment, Transaction
 
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
      delete_project_cache(project)
    end

  end



end
