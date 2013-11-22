class AddMediaSourceTypeToMediaItem < ActiveRecord::Migration
  def change
    add_column :media_items, :media_source_type_id, :integer
    add_index :media_items, :media_source_type_id
  end
end
