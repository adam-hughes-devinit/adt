module RecentChangesHelper

  def association_change_message(change)
    if change.association?
      model = change[:association_model]
      model_id = change[:association_id]

      @item = "#{model.a_or_an.underscore.humanize}"
      @item << " (id: #{model_id})" if model_id

      project_id = change[:project_id]
      @p = Project.find_by_id(project_id)
      @project = @p.to_english

      time = change[:created_at]
      @date = time.strftime("%m/%d")
      @time = time.strftime("%l:%M %P")

      "#{@item} was added to #{link_to @project, @p} on #{@date} at #{@time}."

    elsif change.attribute?
      att = change[:attribute_name]

      project_id = change[:project_id]
      @p = Project.find_by_id(project_id)
      @project = @p.to_english
      time = change[:created_at]
      @date = time.strftime("%m/%d")
      @time = time.strftime("%l:%M %P")


      "#{att.humanize} was updated on #{link_to @project, @p} on #{@date} at #{@time}."

    end


  end
end
