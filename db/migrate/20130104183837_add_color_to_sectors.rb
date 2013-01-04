class AddColorToSectors < ActiveRecord::Migration
  def change
    add_column :sectors, :color, :string
  end
end
