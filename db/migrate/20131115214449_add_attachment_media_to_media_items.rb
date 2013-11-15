class AddAttachmentMediaToMediaItems < ActiveRecord::Migration
  def self.up
    change_table :media_items do |t|
      t.attachment :media
    end
  end

  def self.down
    drop_attached_file :media_items, :media
  end
end
