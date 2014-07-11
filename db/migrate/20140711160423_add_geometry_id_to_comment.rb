class AddGeometryIdToComment < ActiveRecord::Migration
  def change
    add_column :comments, :geometry_id, :integer
  end
end
