class CreateGeometries < ActiveRecord::Migration
  def change
    create_table :geometries do |t|
      t.geometry_collection :the_geom

      t.timestamps
    end
  end
end
