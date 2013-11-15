class CreateMediaItems < ActiveRecord::Migration
  def change
    create_table :media_items do |t|
      t.boolean :publish
      t.references :project

      t.timestamps
    end
    add_index :media_items, :project_id
  end
end
