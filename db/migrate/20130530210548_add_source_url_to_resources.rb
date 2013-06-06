class AddSourceUrlToResources < ActiveRecord::Migration
  def change
    add_column :resources, :source_url, :text
  end
end
