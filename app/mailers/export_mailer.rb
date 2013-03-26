include ApplicationHelper
require 'fileutils'

class ExportMailer < ActionMailer::Base
  default from: "Adamparkerfrey@gmail.com"

  def export_request(export, email)
    # open up a file on the filesystem and write the export to that file
    # Could be a problem if we don't have access to filesystem

    exports_directory = 'public/export_downloads'
    #make directory if not there
    if !(File.directory?(exports_directory))
      FileUtils.mkdir_p(exports_directory)
    end

    @export = export

    time = Time.now
    time = time.strftime("%y-%m-%d--%H%M%S")
    export_file_name = "#{exports_directory}/#{time.to_s}_Aiddata_Export.csv"
    @export.file_path = "export_downloads/#{time.to_s}_Aiddata_Export.csv"
    @export.save

    export_file = File.open(export_file_name, 'w')

    # add is_x scope variable for users to search by scope after exporting
    header = Project.csv_header
    Scope.all.each do |scope|
      header << ", is_scope_#{scope.symbol}?"
    end
    export_file.puts header

    #This is to update the progress bar on the export page
    @export.status_percent = 15 
    @export.save
    count = @export.projects.count
    percent_increase = (45.0 / count) * 10

    @export.projects.each_with_index do |project, index|
      text =  project.csv_text
      # include the boolean value for is_x scope variable from above
      Scope.all.each do |scope|
        text << ", #{project.scope.include?(scope.symbol.to_sym)}"
      end
      export_file.puts text

      if index % 10 == 0
        @export.status_percent += percent_increase
        @export.save
      end
    end
    export_file.close

    mail.attachments['Aiddata_Export.csv'] = {mime_type: 'text/csv',
                                              content: File.read(export_file_name)}
    mail( to: email, subject: "Your Aiddata Export is Ready")
    @export.status_percent = 100
    @export.mailed_status = true
    @export.save


  end
end
