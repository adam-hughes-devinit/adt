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
      scopes = self.scope
      scopes.each { |s| cache_files(s) }
    end

    self
    
  end



  # scope_name is a symbol
  def cache_files(scope_name)
    downloads_directory = 'public/downloads'
    #make directory if not there
    if !(File.directory?(downloads_directory))
      FileUtils.mkdir_p(downloads_directory)
    end
    
    file_prefix = "/#{scope_name.to_s.capitalize}"

    target_file = "#{downloads_directory}#{file_prefix}.csv"

    FileUtils.rm_rf Dir.glob(target_file)

    p target_file

    File.open( target_file ,"w") do |f|
      f.puts "#{Project.csv_header}"
      Project.all.each do |project|
        if project.contains_scope?(scope_name)
          f.puts "#{project.csv_text}"
        end
      end
    end
  end

  handle_asynchronously :cache_files
end
