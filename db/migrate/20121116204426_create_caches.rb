class CreateCaches < ActiveRecord::Migration
  def change
    create_table :caches do |t|
      t.integer :id
      t.text :text

      t.timestamps
    end
  end
end
