class CreateProjectAssociationChanges < ActiveRecord::Migration
  def change
    create_table :project_association_changes do |t|
      t.integer :project_id
      t.string :association_model
      t.integer :association_id

      t.timestamps
    end
  end
end
