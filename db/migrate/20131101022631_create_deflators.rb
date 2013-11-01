class CreateDeflators < ActiveRecord::Migration
  def change
    create_table :deflators do |t|
      t.float :value
      t.integer :year
      t.references :country

      t.timestamps
    end
    add_index :deflators, :country_id
  end
end
