class AddActiveToGeoUpload < ActiveRecord::Migration
  def change
    add_column :geo_uploads, :active, :boolean, :default => false
  end
end
