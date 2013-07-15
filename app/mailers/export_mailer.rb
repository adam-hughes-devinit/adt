include ApplicationHelper
include AmazonHelper
require 'fileutils'

class ExportMailer < ActionMailer::Base
  default from: (ENV['admin_mailer'] || "rmosolgo@aiddata.org")

  def export_request(export, email)
    # open up a file on the filesystem and write the export to that file
    # Could be a problem if we don't have access to filesystem

    exports_directory = 'public/export_downloads'
    filename = 'aiddata_china_export'

    #make directory if not there
    if !(File.directory?(exports_directory))
      FileUtils.mkdir_p(exports_directory)
    end

    @export = export

    time = Time.now
    time = time.strftime("%y-%m-%d--%H%M%S")
    export_file_name = "#{exports_directory}/#{time.to_s}_#{filename}.csv"
    @export.file_path = "export_downloads/#{time.to_s}_#{filename}.csv"

    @export.save

    export_file = File.open(export_file_name, 'w')

    header = Project.csv_header


    export_file.puts header

    #This is to update the progress bar on the export page
    @export.status_percent = 15 
    @export.save
    count = @export.projects.count
    percent_increase = (45.0 / count) * 10

    @export.projects.each_with_index do |project, index|
      text =  project.csv_text

      export_file.puts text

      if index % 10 == 0
        @export.status_percent += percent_increase
        @export.save
      end

    end
    export_file.close

    #send export csv to Amazon s3
    # RDM 4/28 threw an error

    # 2013-04-29T02:53:53.147155+00:00 app[worker.1]: "Uploading file to S3 china_exports"
    # 2013-04-29T02:53:53.147748+00:00 app[worker.1]: [Worker(host:b104afbc-be6e-4b96-8272-528f02f64e53 pid:2)] Class#export_request failed with IOError: closed stream - 0 failed attempts
    # 2013-04-29T02:53:53.163284+00:00 app[worker.1]: [Worker(host:b104afbc-be6e-4b96-8272-528f02f64e53 pid:2)] 1 jobs processed at 0.0066 j/s, 1 failed ...
    # 2013-04-29T02:57:22.599935+00:00 app[worker.1]: "Uploading file to S3 china_exports"
    # 2013-04-29T02:57:22.600421+00:00 app[worker.1]: [Worker(host:b104afbc-be6e-4b96-8272-528f02f64e53 pid:2)] Class#export_request failed with IOError: closed stream - 1 failed attempts

    # s3_upload(ENV['EXPORT_BUCKET'], export_file, "#{filename}.csv")

    # mail it
    mail.attachments["#{filename}.csv"] = {mime_type: 'text/csv',
                                              content: File.read(export_file_name)}
    mail( to: email, subject: "Your AidData export is ready!")
    @export.status_percent = 100
    @export.mailed_status = true
    @export.save

  end
end
