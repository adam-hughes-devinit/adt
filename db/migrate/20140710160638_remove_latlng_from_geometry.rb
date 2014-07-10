class RemoveLatlngFromGeometry < ActiveRecord::Migration
  def up
    remove_column :geometries, :latitude
    remove_column :geometries, :longitude
  end

  def down
    add_column :geometries, :longitude, :decimal
    add_column :geometries, :latitude, :decimal
  end
end
