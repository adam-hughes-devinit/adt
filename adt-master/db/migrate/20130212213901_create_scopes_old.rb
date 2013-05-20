class CreateScopesOld < ActiveRecord::Migration
  def change
    create_table :scopes do |t|
      t.string :name
      t.text :hint
      t.string :type
      t.string :symbol

      t.timestamps
    end
  end
end
