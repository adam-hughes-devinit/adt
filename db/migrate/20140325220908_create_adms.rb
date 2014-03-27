class CreateAdms < ActiveRecord::Migration
  def change
    create_table :adms do |t|
      t.integer :code
      t.string :name
      t.integer :level
      t.integer :geometry_id
      t.integer :parent_id

      t.timestamps
    end
    add_index :adms, :geometry_id
    add_index :adms, :parent_id
  end
end
