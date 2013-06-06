include ApplicationHelper

class AiddataAdminMailer < ActionMailer::Base
  default from: ENV['admin_mailer']
  default to: ENV['admin_mail_receiver']
  
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



end
