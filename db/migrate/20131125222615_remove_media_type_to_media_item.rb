class RemoveMediaTypeToMediaItem < ActiveRecord::Migration
  def up
    remove_column :media_items, :media_type
  end

  def down
    add_column :media_items, :media_type, :string
  end
end
