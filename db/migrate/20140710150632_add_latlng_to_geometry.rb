class AddLatlngToGeometry < ActiveRecord::Migration
  def change
    add_column :geometries, :latitude, :decimal
    add_column :geometries, :longitude, :decimal
  end
end
