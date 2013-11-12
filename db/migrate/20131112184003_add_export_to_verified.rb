class AddExportToVerified < ActiveRecord::Migration
  def change
    add_column :verifieds, :export, :bool
  end
end
