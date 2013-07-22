module RecentChangesHelper

  def association_change_message(change)
    project_id = change[:project_id]
    p = Project.find_by_id(project_id)
    project = p.to_english

    rawtime = change[:created_at]
    date = rawtime.strftime("%m/%d")
    time = rawtime.strftime("%l:%M %P")

    user_id = change[:user_id]
    if user_id && user_record = User.find_by_id(user_id)
      user = user_record.email
      name = user_record.name
      user = name if name
    end

    if change.association?
      model = change[:association_model]
      model_id = change[:association_id]

      item = "#{model.a_or_an.underscore.humanize}"
      item << " (id: #{model_id})" if model_id

      message = "#{item} was added to #{link_to project, p}"
      message << " on #{date} at #{time}"
      message << " by #{user}" if user
      message << "."

    elsif change.attribute?
      att = change[:attribute_name]



      message = "#{att.humanize} was updated on #{link_to project, p}"
      message << " on #{date} at #{time}"
      message << " by #{user}" if user
      message << "."
    end


  end
end
