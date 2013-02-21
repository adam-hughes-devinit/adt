include ApplicationHelper
require 'fileutils'

class ExportMailer < ActionMailer::Base
  default from: "Adamparkerfrey@gmail.com"

  def export_request(export, email)
    export_file = File.open('export.csv', 'w')
    export_file.puts Project.csv_header
    # @export_projects = export[:projects]
    @export = export
    @export.projects.each do |project|
      export_file.puts project.csv_text
    end
    export_file.close

    attachment "text/csv" do |a|
      a.body = File.read('export.csv')
      a.filename = "Aiddata_Export.csv"
    end

    mail( to: email, subject: "Your Export is Ready")

    FileUtils.rm_rf 'export.csv'
  end
end
