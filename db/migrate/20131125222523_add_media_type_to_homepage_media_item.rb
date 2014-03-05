class AddMediaTypeToHomepageMediaItem < ActiveRecord::Migration
  def change
    add_column :homepage_media_items, :media_item_type_id, :integer
    add_index :homepage_media_items, :media_item_type_id
  end
end
