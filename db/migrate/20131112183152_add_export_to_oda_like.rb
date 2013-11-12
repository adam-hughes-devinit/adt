class AddExportToOdaLike < ActiveRecord::Migration
  def change
    add_column :oda_likes, :export, :bool
  end
end
