class CreateGeocodes < ActiveRecord::Migration
  def change
    create_table :geocodes do |t|
      t.integer :project_id
      t.integer :geo_name_id
      t.integer :precision_id
      t.integer :location_type_id
      t.float :latitude
      t.float :longitude
      t.text :note

      t.timestamps
    end
  end
end
