class CreateIntents < ActiveRecord::Migration
  def change
    create_table :intents do |t|
      t.string :name
      t.integer :code
      t.text :description

      t.timestamps
    end
  end
end
