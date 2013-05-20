class CreateOrganizationTypes < ActiveRecord::Migration
  def change
    create_table :organization_types do |t|
      t.string :name
      t.integer :iati_code

      t.timestamps
    end
  end
end
