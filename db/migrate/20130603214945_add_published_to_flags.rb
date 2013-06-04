class AddPublishedToFlags < ActiveRecord::Migration
  def change
    add_column :flags, :published, :boolean, :default => true
  end
end
