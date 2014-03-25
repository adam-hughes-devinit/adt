class CreateAdms < ActiveRecord::Migration
  def change
    create_table :adms do |t|
      t.string :code
      t.string :name
      t.integer :level
      t.multi_polygon :the_geom

      t.timestamps
    end
  end
end
