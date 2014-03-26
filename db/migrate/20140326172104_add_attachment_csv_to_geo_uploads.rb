class AddAttachmentCsvToGeoUploads < ActiveRecord::Migration
  def self.up
    change_table :geo_uploads do |t|
      t.attachment :csv
    end
  end

  def self.down
    drop_attached_file :geo_uploads, :csv
  end
end
