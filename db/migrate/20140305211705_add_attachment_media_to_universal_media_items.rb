class AddAttachmentMediaToUniversalMediaItems < ActiveRecord::Migration
  def self.up
    change_table :universal_media_items do |t|
      t.attachment :media
    end
  end

  def self.down
    drop_attached_file :universal_media_items, :media
  end
end
