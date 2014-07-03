class AddStatusToGeoUpload < ActiveRecord::Migration
  def up
    add_column :geo_uploads, :status, :integer, default: 0
  end

  def down
    remove_column :geo_uploads, :status
  end
end
