class AddUsdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :usd_2009, :integer
  end
end
