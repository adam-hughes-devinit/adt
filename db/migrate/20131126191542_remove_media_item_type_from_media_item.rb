class RemoveMediaItemTypeFromMediaItem < ActiveRecord::Migration
  def up
    remove_column :media_items, :media_item_type_id
  end

  def down
    add_column :media_items, :media_item_type_id, :integer
  end
end
