class CreateParticipatingOrganizations < ActiveRecord::Migration
  def change
    create_table :participating_organizations do |t|
      t.integer :role_id
      t.integer :project_id
      t.integer :organization_id

      t.timestamps
    end
  end
end
