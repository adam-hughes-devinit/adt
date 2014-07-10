class RemoveIndividualLatlngsFromComments < ActiveRecord::Migration
  def up
    remove_column :comments, :verboselat
    remove_column :comments, :verboselng
    remove_column :comments, :latlng
  end

  def down
    add_column :comments, :latlng, :string
    add_column :comments, :verboselng, :decimal
    add_column :comments, :verboselat, :decimal
  end
end
