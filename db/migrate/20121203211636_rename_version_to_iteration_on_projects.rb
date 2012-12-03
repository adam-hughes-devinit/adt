class RenameVersionToIterationOnProjects < ActiveRecord::Migration
  def change
  	rename_column :projects, :version, :iteration
  end

end
