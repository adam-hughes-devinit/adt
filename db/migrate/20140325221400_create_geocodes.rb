class CreateGeocodes < ActiveRecord::Migration
  def change
    create_table :geocodes do |t|
      t.integer :project_id
      t.integer :geo_name_id
      t.integer :precision_id
      t.text :note

      t.timestamps
    end
    add_index :geocodes, :project_id
    add_index :geocodes, :geo_name_id
    add_index :geocodes, :precision_id
  end
end
