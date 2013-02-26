include ApplicationHelper

class AiddataAdminMailer < ActionMailer::Base
  default from: "adamparkerfrey@gmail.com"
  default to: "adamparkerfrey@gmail.com"

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

end
