class AddMediaTypeToMediaItem < ActiveRecord::Migration
  def change
    add_column :media_items, :media_type, :string
  end
end
