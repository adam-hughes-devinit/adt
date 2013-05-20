class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :name
      t.string :iso3
      t.string :iso2
      t.string :oecd_name
      t.integer :oecd_code
      t.integer :cow_code

      t.timestamps
    end
  end
end
