class AiddataAdminMailer < ActionMailer::Base
  default from: "rmosolgo@aiddata.org"
  
  def comment_notification(comment)
  	@comment = comment
  	@aiddata_admin_emails = User.where(owner_id: Organization.find_by_name('AidData').id, admin: true).map(&:email)
  	mail to: @aiddata_admin_emails, subject: "New Comment on Project #{@comment.project.id}"
  end

  def flag_notification()
  end
  	
  
end
