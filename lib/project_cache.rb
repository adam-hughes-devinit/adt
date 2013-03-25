module ProjectCache
  include ProjectExporters
  require 'fileutils'

  def cache!(options = {now: false, include_files: true })

    if options[:now]
      cached_record = Cache.find_or_create_by_id(id)
      cached_record.update_attribute(:text, self.csv_text)
    else
      cached_record = Cache.find_or_create_by_id(id)
      cached_record.delay.update_attribute(:text, self.csv_text)
    end

    if options[:include_files]
      self.scope.each { |s| cache_files(s) }
    end

    self
    
  end



  # scope_name is a symbol
  def cache_files(scope_symbol=nil)

    downloads_directory = 'public/downloads'
    # make directory if not there
    if !(File.directory?(downloads_directory))
      FileUtils.mkdir_p(downloads_directory)
    end
    
    if !scope_symbol
      #Remove all the old csv files
      FileUtils.rm_rf Dir["#{downloads_directory}/*.csv"]

      # create a csv file for each scope
      scopes = Scope.all
      file_hash = {}
      scopes.each do |scope_object|
        name = scope_object.symbol.to_s.capitalize
        file_hash[scope_object.symbol.to_sym] = 
          File.open("#{downloads_directory}/#{name}.csv", 'w')
      end
      all_proj_file = File.open("#{downloads_directory}/All_Projects.csv",'w')

      # add the csv_header to each file
      file_hash.each do |name, file|
        file.puts Project.csv_header
      end
      all_proj_file.puts Project.csv_header

      #grab all the projects
      all_project = Project.search do
        paginate per_page: 10**6
      end.results

      # iterate through the projects and place the info in the
      # appropriate files
      all_project.each do |project|
        proj_scopes = project.scope
        proj_scopes.each do |proj_scope|
          file = file_hash[proj_scope]
          file.puts project.csv_text
        end
        all_proj_file.puts project.csv_text
      end

      #close all the files
      file_hash.each do |name, file|
        file.close
      end
    else
      file_prefix = "/#{scope_symbol.to_s.capitalize}"

      target_file = "#{downloads_directory}#{file_prefix}.csv"

      FileUtils.rm_rf Dir.glob(target_file)

      p "Creating #{target_file}"

      these_projects = Project.search do 
        with :scope, scope_symbol
        paginate per_page: 10**5
      end.results

      if !these_projects.blank?
        File.open( target_file ,"w") do |f|
          
          f.puts "#{Project.csv_header}"

          these_projects.each do |project|
            f.puts "#{project.csv_text}"
          end
        end
      end

    end
  end

  handle_asynchronously :cache_files
end
