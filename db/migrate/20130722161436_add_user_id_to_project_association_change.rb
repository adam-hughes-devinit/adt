class AddUserIdToProjectAssociationChange < ActiveRecord::Migration
  def change
    add_column :project_association_changes, :user_id, :integer
  end
end
