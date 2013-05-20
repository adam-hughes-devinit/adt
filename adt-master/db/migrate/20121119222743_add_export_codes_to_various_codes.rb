class AddExportCodesToVariousCodes < ActiveRecord::Migration
  def change
  	add_column :statuses, :code, :integer
  	add_column :tieds, :code, :integer
  	add_column :verifieds, :code, :integer
  	add_column :oda_likes, :code, :integer
  end
end
