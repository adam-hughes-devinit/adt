class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.integer :source_type_id
      t.integer :document_type_id
      t.string :url
      t.date :date
      t.integer :project_id

      t.timestamps
    end
  end
end
