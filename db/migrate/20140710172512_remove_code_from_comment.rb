class RemoveCodeFromComment < ActiveRecord::Migration
  def up
    remove_column :comments, :code
  end

  def down
    add_column :comments, :code, :string
  end
end
