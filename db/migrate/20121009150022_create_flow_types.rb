class CreateFlowTypes < ActiveRecord::Migration
  def change
    create_table :flow_types do |t|
      t.string :name
      t.integer :iati_code
      t.integer :aiddata_code
      t.integer :oecd_code

      t.timestamps
    end
  end
end
