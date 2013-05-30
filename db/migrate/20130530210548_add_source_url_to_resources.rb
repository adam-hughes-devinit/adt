class AddSourceUrlToResources < ActiveRecord::Migration
  def change
    add_column :resources, :source_url, :string
  end
end
