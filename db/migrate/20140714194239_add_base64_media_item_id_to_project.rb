class AddBase64MediaItemIdToProject < ActiveRecord::Migration
  def change
    add_column :projects, :base64_media_item_id, :integer
  end
end
