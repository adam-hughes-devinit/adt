class CreateScopes < ActiveRecord::Migration
  def change
    create_table :scopes do |t|
      t.string :name
      t.text :description
      t.string :symbol

      t.timestamps
    end
  end
end
