class AddUserToMediaItem < ActiveRecord::Migration
  def change
    add_column :media_items, :user_id, :integer
    add_index  :media_items, :user_id
  end
end
