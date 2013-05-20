class CreateScopeRequirements < ActiveRecord::Migration
  def change
    create_table :scope_requirements do |t|
      t.integer :scope_id
      t.string :field
      t.string :value

      t.timestamps
    end
  end
end
