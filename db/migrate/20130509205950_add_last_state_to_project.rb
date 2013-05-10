class AddLastStateToProject < ActiveRecord::Migration
  def change
    add_column :projects, :last_state, :text
  end
end
