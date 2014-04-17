class AddAttachmentLogToGeoUploads < ActiveRecord::Migration
  def self.up
    change_table :geo_uploads do |t|
      t.attachment :log
    end
  end

  def self.down
    drop_attached_file :geo_uploads, :log
  end
end
