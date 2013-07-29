class ProjectAssociationChange < ActiveRecord::Base
  attr_accessible :association_id, :association_model, :project_id,
                  :attribute_name, :user_id


  def association?
    if association_model
      true
    else
      false
    end
  end

  def attribute?
    if attribute_name
      true
    else
      false
    end
  end

  # call this after ProjAssChange Creation to update the cache of most
  # recent changes.
  def cache_change
    @project = Project.find_by_id(project_id)
    if @project.is_stage_one == "Is not Stage One" && @project.active == true && attribute_name != 'active'


      first = Rails.cache.fetch("recent/first")

      # if the last project was the same as this one, store it in the string
      # instead of making a new entry
      if first && first[:id] == project_id
        action = first[:action]
        new_action = "#{(attribute_name || "#{association_model}s").titleize.downcase}"

        #no duplicates
        unless /#{new_action}/ =~ action
          first[:action] = action << ", #{new_action}"
          first[:time] = self.updated_at
          Rails.cache.write("recent/first", first)
        else
          false
        end

      else
        # add a new entry and move the old ones down
        second = Rails.cache.fetch("recent/second")

        Rails.cache.write("recent/third", second)
        Rails.cache.write("recent/second", first)
        @update_sent = "updated #{(attribute_name || "#{association_model}s").titleize.downcase}"
        json = {
          id: @project.id,
          title: @project.title,
          info: @project.to_english(exclude_title: true),
          action: @update_sent,
          time: self.updated_at
        }

        Rails.cache.write("recent/first", json)
      end
    else
      false
    end
  end


end
