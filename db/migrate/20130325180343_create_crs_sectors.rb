class CreateCrsSectors < ActiveRecord::Migration
  def change
    create_table :crs_sectors do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
  end
end
