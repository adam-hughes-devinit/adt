class AddAttachmentHomeMediaToHomepageMediaItems < ActiveRecord::Migration
  def self.up
    change_table :homepage_media_items do |t|
      t.attachment :home_media
    end
  end

  def self.down
    drop_attached_file :homepage_media_items, :home_media
  end
end
