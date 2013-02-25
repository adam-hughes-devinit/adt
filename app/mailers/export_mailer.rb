include ApplicationHelper
require 'fileutils'

class ExportMailer < ActionMailer::Base
  default from: "Adamparkerfrey@gmail.com"

  def export_request(export, email)
    # open up a file on the filesystem and write the export to that file
    # Could be a problem if we don't have access to filesystem

    exports_directory = 'public/exports'
    #make directory if not there
    if !(File.directory?(exports_directory))
      FileUtils.mkdir_p(exports_directory)
    end

    date = Time.now
    export_file_name = "#{exports_directory}/#{date.to_s}.csv"
    export_file = File.open(export_file_name, 'w')
    export_file.puts Project.csv_header
    @export = export

    #This is to update the progress bar on the export page
    @export.status_percent = 15 
    @export.save
    count = @export.projects.count
    percent_increase = (75.0 / count) * 10

    @export.projects.each_with_index do |project, index|
      export_file.puts project.csv_text

      if index % 10 == 0
        @export.status_percent += percent_increase
        @export.save
      end
    end
    export_file.close

    mail.attachments['Aiddata_Export.csv'] = {mime_type: 'text/csv',
                                              content: File.read(export_file_name)}
    mail( to: email, subject: "Your Export is Ready")
    @export.status_percent = 100
    @export.save

  end
end
