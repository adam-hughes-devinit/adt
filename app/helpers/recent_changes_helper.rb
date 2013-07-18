module RecentChangesHelper
  def change_message(item)
    item_type = item['item_type']
    id = item['item_id']
    actor = item['whodunnit']
    time = item['created_at']

    object = item_type.constantize.find_by_id(id)
    project = object.project if object.respond_to? :project

    article = 'a'
    article = 'an' if ['a','e','i','o'].include? item_type[0].downcase

    if project
      p_link = link_to project.to_english, project

      i_link = "#{item_type} (id: #{id})"

      @first_part = "On #{p_link}, #{article} #{i_link} "
    else

      i_link = "#{item_type} (id: #{id})"
      @first_part = "#{article.capitalize} #{i_link}"
    end

    @actor_clause = ""
    if actor
      user = User.find_by_id(actor)
      @actor_clause << " by #{user.email}" if user
    end

    past_tense = "destroyed" if item['event'] == 'destroy'
    past_tense = "updated" if item['event'] == 'update'
    past_tense = "created" if item['event'] == 'create'
    @last_part = " was #{past_tense} on "\
    "#{time.strftime("%m/%d")} at #{time.strftime("%l:%M %P")}"

    "#{@first_part}#{@last_part}#{@actor_clause}"
  end
end
