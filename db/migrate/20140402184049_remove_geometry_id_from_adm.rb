class RemoveGeometryIdFromAdm < ActiveRecord::Migration
  def up
    remove_column :adms, :geometry_id
  end

  def down
    add_column :adms, :geometry_id, :integer
  end
end
