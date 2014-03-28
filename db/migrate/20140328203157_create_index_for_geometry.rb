class CreateIndexForGeometry < ActiveRecord::Migration
  def up
    add_index :geometries, :the_geom, :spatial => true
  end

  def down
    remove_index :geometries, :the_geom
  end
end
