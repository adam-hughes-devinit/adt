class AddStatusToExports < ActiveRecord::Migration
  def change
    add_column :exports, :mailed_status, :boolean
  end
end
