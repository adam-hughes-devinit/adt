class AddPublishedToComments < ActiveRecord::Migration
  def change
    add_column :comments, :published, :boolean, :default => true
  end
end
