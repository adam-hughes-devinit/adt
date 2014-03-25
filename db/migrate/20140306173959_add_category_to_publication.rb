class AddCategoryToPublication < ActiveRecord::Migration
  def change
    add_column :publications, :category, :string
  end
end
