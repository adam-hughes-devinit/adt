class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :organization_id
      t.string :name
      t.string :position
      t.integer :project_id

      t.timestamps
    end
  end
end
