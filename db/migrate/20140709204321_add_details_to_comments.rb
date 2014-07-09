class AddDetailsToComments < ActiveRecord::Migration
  def change
    add_column :comments, :verboselat, :decimal
    add_column :comments, :verboselng, :decimal
    add_column :comments, :geocode_id, :integer
    add_column :comments, :filename, :string
    add_column :comments, :filedata, :string
    add_column :comments, :latlng, :string
  end
end
