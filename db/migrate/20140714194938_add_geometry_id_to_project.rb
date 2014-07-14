class AddGeometryIdToProject < ActiveRecord::Migration
  def change
    add_column :projects, :geometry_id, :integer
  end
end
