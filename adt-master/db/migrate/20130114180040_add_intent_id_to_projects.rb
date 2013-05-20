class AddIntentIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :intent_id, :integer
  end
end
