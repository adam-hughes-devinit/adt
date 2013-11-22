class AddTextFieldsToMediaItem < ActiveRecord::Migration
  def change
    add_column :media_items, :homepage_text, :string
    add_column :media_items, :download_text, :string
  end
end
