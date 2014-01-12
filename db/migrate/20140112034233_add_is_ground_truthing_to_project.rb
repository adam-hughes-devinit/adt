class AddIsGroundTruthingToProject < ActiveRecord::Migration
  def change
    add_column :projects, :is_ground_truthing, :boolean
  end
end
