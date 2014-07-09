class RemoveFilesFromComments < ActiveRecord::Migration
  def up
    remove_column :comments, :filename
    remove_column :comments, :filedata
  end

  def down
    add_column :comments, :filedata, :string
    add_column :comments, :filename, :string
  end
end
