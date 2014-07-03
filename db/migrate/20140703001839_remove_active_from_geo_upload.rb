class RemoveActiveFromGeoUpload < ActiveRecord::Migration
  def up
    remove_column :geo_uploads, :active
  end

  def down
    add_column :geo_uploads, :active, :boolean
  end
end
