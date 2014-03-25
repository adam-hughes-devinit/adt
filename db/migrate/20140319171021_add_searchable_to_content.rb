class AddSearchableToContent < ActiveRecord::Migration
  def change
    add_column :contents, :searchable, :boolean, default: false
  end
end
