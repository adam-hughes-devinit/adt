class CreateGeoNames < ActiveRecord::Migration
  def change
    create_table :geo_names do |t|
      t.integer :code
      t.string :name
      t.decimal :latitude
      t.decimal :longitude
      t.integer :location_type_id

      t.timestamps
    end
    add_index :geo_names, :location_type_id
  end
end
