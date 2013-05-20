class AddStatusPercentToExports < ActiveRecord::Migration
  def change
    add_column :exports, :status_percent, :integer
  end
end
