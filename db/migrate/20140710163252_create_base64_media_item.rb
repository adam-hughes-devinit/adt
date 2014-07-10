class CreateBase64MediaItem < ActiveRecord::Migration
  def change
    create_table :base64_media_items do |t|

      t.timestamps
    end
  end
end
