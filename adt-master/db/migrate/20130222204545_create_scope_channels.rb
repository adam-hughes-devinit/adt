class CreateScopeChannels < ActiveRecord::Migration
  def change
    create_table :scope_channels do |t|
      t.integer :scope_id

      t.timestamps
    end
  end
end
