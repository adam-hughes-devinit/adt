class CreateAdmGeos < ActiveRecord::Migration
  def change
    create_table :adm_geos do |t|
      t.integer :geocode_id
      t.integer :adm_id

      t.timestamps
    end
  end
end
