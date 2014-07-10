class AddForeignKeysToComments < ActiveRecord::Migration
  def change
    add_column :comments, :base64_media_item_id, :integer
    add_column :comments, :code, :integer
  end
end
