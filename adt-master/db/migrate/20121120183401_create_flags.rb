class CreateFlags < ActiveRecord::Migration
  def change
    create_table :flags do |t|
      t.integer :flaggable_id
      t.string :flaggable_type
      t.integer :flag_type
      t.string :source
      t.text :comment
      t.integer :owner_id

      t.timestamps
    end
  end
end
