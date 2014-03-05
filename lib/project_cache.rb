module ProjectCache
  include ProjectExporters
  require 'fileutils'
  require 'open-uri'

  def delete_project_cache(project)
    # Expire search bar cache
    Rails.cache.delete("projects/#{project.id}/to_english/no_title")
    Rails.cache.delete("projects/#{project.id}/to_english/title")

    # expire the Show page(s) no that it is changed
    Rails.cache.delete("projects/#{project.id}/signed_in/aiddata")
    Rails.cache.delete("projects/#{project.id}/signed_in/non_aiddata")
    Rails.cache.delete("projects/#{project.id}/not_signed_in/non_aiddata")

    # expire the Search Results now that it is changed
    Rails.cache.delete("views/projects/#{project.id}/search_result/aiddata")
    Rails.cache.delete("views/projects/#{project.id}/search_result/non_aiddata")
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


  # scope_name is a symbol
  def cache_files(scope_symbol=nil)
    
    p "cache_files = NO OP on heroku"

    # # go ahead and load csv_text in memory:
    # Project.find_each do |p| p.csv_text end

    # downloads_directory = 'public/downloads'
    # # make directory if not there
    # if !(File.directory?(downloads_directory))
    #   FileUtils.mkdir_p(downloads_directory)
    # end
    
    # root = Rails.env.production? ? "http://china.aiddata.org" : 'http://localhost:3000'
    # def make_file_for_scope(scope, downloads_directory, root)  
    #   name = scope.name
    #   File.open("#{downloads_directory}/#{name}.csv", 'w') do |file|
    #     file.puts open(URI.encode(root + "/projects.csv?scope_names[]=#{name}"))
    #   end
    # end

    

    
    # if !scope_symbol
    #   #Remove all the old csv files
    #   FileUtils.rm_rf Dir["#{downloads_directory}/*.csv"]

    #   # create a csv file for each scope 
    #   scopes = Scope.all
    #   scopes.each do |scope|
    #     make_file_for_scope(scope, downloads_directory,root)
    #   end
    # else

    #   make_file_for_scope(Scope.find_by_symbol(scope_symbol), downloads_directory, root)
    # end

    # # Always remake the whole file
    # File.open("#{downloads_directory}/All_Projects.csv",'w') do |file|
    #   file.puts open(root +"/projects.csv")
    # end
  end

  handle_asynchronously :cache_files
end
