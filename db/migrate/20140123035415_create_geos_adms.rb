class CreateGeosAdms < ActiveRecord::Migration
  def change
    create_table :geocodes_adms, :id => false do |t|
      t.integer :geocode_id
      t.integer :adm_id

      t.timestamps
    end
    add_index :geocodes_adms, [:geocode_id, :adm_id]
  end
end
