class CreateGeoUploads < ActiveRecord::Migration
  def change
    create_table :geo_uploads do |t|
      t.integer :record_count

      t.timestamps
    end
  end
end
