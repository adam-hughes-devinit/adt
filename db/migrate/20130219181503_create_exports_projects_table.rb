class CreateExportsProjectsTable < ActiveRecord::Migration
  def up
    create_table :exports_projects, id: false do |t|
      t.references :export
      t.references :project
    end
    add_index :exports_projects, [:export_id, :project_id]
    add_index :exports_projects, [:project_id, :export_id]
  end

  def down
    drop_table :exports_projects
  end
end
