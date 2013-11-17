class RemoveEmbedCodeFromMediaItem < ActiveRecord::Migration
  def up
    remove_column :media_items, :embed_code
  end

  def down
    add_column :media_items, :embed_code, :text
  end
end
