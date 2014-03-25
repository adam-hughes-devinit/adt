class CreateAdmsGeocodesTable < ActiveRecord::Migration
  def self.up
    create_table :adms_geocodes, :id => false do |t|
      t.references :adm
      t.references :geocode
    end
    add_index :adms_geocodes, [:adm_id, :geocode_id]
    add_index :adms_geocodes, :geocode_id
  end

  def self.down
    drop_table :adms_geocodes
  end
end
