class CreateGeopoliticals < ActiveRecord::Migration
  def change
    create_table :geopoliticals do |t|
      t.integer :recipient_id
      t.integer :region_id
      t.integer :project_id
      t.string :subnational
      t.integer :percent

      t.timestamps
    end
  end
end
