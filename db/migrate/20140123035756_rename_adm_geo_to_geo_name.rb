class RenameAdmGeoToGeoName < ActiveRecord::Migration
  def up
    rename_table :adm_geos, :geo_names
  end

  def down
    rename_table :geo_names, :adm_geos
  end
end
