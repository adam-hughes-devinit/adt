class CreateGeoNames < ActiveRecord::Migration
  def change
    create_table :geo_names do |t|
      t.string :name
      t.integer :code

      t.timestamps
    end
  end
end
