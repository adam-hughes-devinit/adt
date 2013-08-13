include ApplicationHelper

class AiddataAdminMailer < ActionMailer::Base
  default from: (ENV['admin_mailer'] || (Rails.env.development? ? "rmosolgo@aiddata.org" : nil))
  default to: (ENV['admin_mail_receiver'] || (Rails.env.development? ? "rmosolgo@aiddata.org" : nil))

  def mail_logger
    @@mail_logger ||= Logger.new("#{Rails.root}/log/mail.log")
  end

  def comment_notification(comment)
    @comment = comment
    mail subject: "New Comment on Project #{@comment.project.id}"
  end

  def flag_notification(flag)
    @flag = flag
    if PROJECT_ACCESSORY_OBJECTS.include?(@flag.flaggable_type)
      proj_id = (@flag.flaggable_type.constantize).find(@flag.flaggable_id).project.id
    else
      proj_id = @flag.flaggable_id
    end
    @flag = flag
    mail subject: "New Flag on Project #{proj_id}"
    mail_logger.info ENV['admin_mailer']
    mail_logger.info ENV['admin_mail_receiver']

  end

  def file_notification(project)
    @project = project
    mail subject: "New file on Project #{@project.id}"
  end

  def pending_content_notification(pending_content, was_approved=nil)
    @content = pending_content
    @was_approved = was_approved
    @handled = 
      if @was_approved
        "confirmed"
      else
        if @was_approved == false
          "denied"
        else
          "submitted"
        end
      end
    mail subject: "Pending content was #{@handled}"
  end

  def contributor_notification(contribution, project, user)
    if user.email
      if contribution.is_a? String
        @contribution_type = contribution
      else
        @contribution_type = contribution.class.name.titleize 
      end
      @project = project
      mail to: user.email, subject: "Thanks for your contribution to China.AidData.org"
    end
  end

end
