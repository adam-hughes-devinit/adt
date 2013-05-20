class AddVersionToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :version, :integer, default: 0
  end
end
