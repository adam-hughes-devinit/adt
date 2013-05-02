class AddChildrenToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :children, :text
  end
end
