class AddIsCofinancedToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :is_cofinanced, :boolean, default: false
  end
end
