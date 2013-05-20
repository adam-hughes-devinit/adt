class AddAccessoriesToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :accessories, :text
  end
end
