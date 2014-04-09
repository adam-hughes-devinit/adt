class AddCodeToGeometries < ActiveRecord::Migration
  def change
    add_column :geometries, :adm_code, :integer
    add_index :geometries, :adm_code
  end
end
