include ApplicationHelper

class ExportMailer < ActionMailer::Base
  default from: "china@aiddata.org"

  def export_request(search, email)
  end
end
