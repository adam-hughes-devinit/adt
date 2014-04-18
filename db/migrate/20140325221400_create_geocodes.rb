class CreateGeocodes < ActiveRecord::Migration
  def change
    create_table :geocodes do |t|
      t.integer :project_id
      t.integer :geo_name_id
      t.integer :precision_id
      t.integer :geometry_id
      t.integer :geo_upload_id
      t.integer :adm_id

      t.timestamps
    end
    add_index :geocodes, :project_id
    add_index :geocodes, :geo_name_id
    add_index :geocodes, :precision_id
    add_index :geocodes, :geometry_id
    add_index :geocodes, :geo_upload_id
    add_index :geocodes, :adm_id
  end
end
