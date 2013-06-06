class AddProjectsCountToResources < ActiveRecord::Migration
  def change
    add_column :resources, :projects_count, :integer, default: 0
  end
end
