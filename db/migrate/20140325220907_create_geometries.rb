class CreateGeometries < ActiveRecord::Migration
  def change
    create_table :geometries do |t|
      t.geometry_collection :the_geom, :srid => 4326

      t.timestamps
    end
  end
end
