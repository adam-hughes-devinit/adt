class CreateScopeFilters < ActiveRecord::Migration
  def change
    create_table :scope_filters do |t|
      t.string :field
      t.integer :scope_channel_id

      t.timestamps
    end
  end
end
