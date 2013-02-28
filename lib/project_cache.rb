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
  def cache_files(scope_symbol)


    ## REFACTOR TO WORK LIKE THIS
    #
    # accept param for scope
    # 1) if scope, then do what it does now
    #
    # otherwise remake all
    #
    # 1) remove old files (in case scope inventory has changed)
    # 2) make new empty CSV file for each scope
    # 3) for each project, get its scopes
    # 4) insert that project's csv_text into the right files
    # 5) be done. only loop through projects once to make all files

    downloads_directory = 'public/downloads'
    # make directory if not there
    if !(File.directory?(downloads_directory))
      FileUtils.mkdir_p(downloads_directory)
    end
    
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

  handle_asynchronously :cache_files
end
