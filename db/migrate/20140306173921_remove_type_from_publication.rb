class RemoveTypeFromPublication < ActiveRecord::Migration
  def up
    remove_column :publications, :type
  end

  def down
    add_column :publications, :type, :string
  end
end
