class AddColsToBase64MediaItem < ActiveRecord::Migration
  def change
    add_column :base64_media_items, :comment_id, :integer
  end
end
