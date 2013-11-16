class AddColumnsToMediaItem < ActiveRecord::Migration
  def change
    add_column :media_items, :url, :string
    add_column :media_items, :embed_code, :text
    add_column :media_items, :downloadable, :boolean
  end
end
