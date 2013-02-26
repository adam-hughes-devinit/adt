class AddFilePathToExports < ActiveRecord::Migration
  def change
    add_column :exports, :file_path, :string
  end
end
