class RemoveCommentIdFromBase64MediaItem < ActiveRecord::Migration
  def up
    remove_column :base64_media_items, :comment_id
  end

  def down
    add_column :base64_media_items, :comment_id, :integer
  end
end
