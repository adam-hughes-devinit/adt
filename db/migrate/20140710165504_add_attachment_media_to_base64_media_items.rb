class AddAttachmentMediaToBase64MediaItems < ActiveRecord::Migration
  def self.up
    change_table :base64_media_items do |t|
      t.attachment :media
    end
  end

  def self.down
    drop_attached_file :base64_media_items, :media
  end
end
