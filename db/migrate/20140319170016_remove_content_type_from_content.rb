class RemoveContentTypeFromContent < ActiveRecord::Migration
  def up
    remove_column :contents, :content_type
  end

  def down
    add_column :contents, :content_type, :string
  end
end
