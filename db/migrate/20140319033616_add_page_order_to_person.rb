class AddPageOrderToPerson < ActiveRecord::Migration
  def change
    add_column :people, :page_order, :integer
  end
end
