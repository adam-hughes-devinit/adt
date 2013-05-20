include ApplicationHelper

class AiddataAdminMailer < ActionMailer::Base
  default from: "rmosolgo@aiddata.org"
  default to: "china@aiddata.org"

  def comment_notification(comment)
    @comment = comment
    if Rails.env.production?
      mail subject: "New Comment on Project #{@comment.project.id}"
    end
  end

  def flag_notification(flag)
    @flag = flag
    if PROJECT_ACCESSORY_OBJECTS.include?(@flag.flaggable_type)
      proj_id = (@flag.flaggable_type.constantize).find(@flag.flaggable_id).project.id
    else
      proj_id = @flag.flaggable_id
    end
    @flag = flag
    if Rails.env.production?
      mail subject: "New Flag on Project #{proj_id}"
    end
  end

  def file_notification(project)
    @project = project
    if Rails.env.production?
      mail subject: "New file on Project #{@project.id}"
    end
  end

  def review_entry_notification(review_entry, was_approved=false)
    @review_entry = review_entry
    @was_approved = was_approved
    @handled = @was_approved ? "confirmed" : "denied"
    if true # Rails.env.production?
      mail subject: "Pending content was #{@handled}"
    end
  end



end
