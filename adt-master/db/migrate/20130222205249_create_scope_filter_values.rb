class CreateScopeFilterValues < ActiveRecord::Migration
  def change
    create_table :scope_filter_values do |t|
      t.string :value
      t.integer :scope_field_id

      t.timestamps
    end
  end
end
