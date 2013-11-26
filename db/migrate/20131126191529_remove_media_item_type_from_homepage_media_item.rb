class RemoveMediaItemTypeFromHomepageMediaItem < ActiveRecord::Migration
  def up
    remove_column :homepage_media_items, :media_item_type_id
  end

  def down
    add_column :homepage_media_items, :media_item_type_id, :integer
  end
end
