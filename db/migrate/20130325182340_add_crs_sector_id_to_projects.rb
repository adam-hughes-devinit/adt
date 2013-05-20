class AddCrsSectorIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :crs_sector_id, :integer
  end
end
