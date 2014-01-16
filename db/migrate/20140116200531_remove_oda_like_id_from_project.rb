class RemoveOdaLikeIdFromProject < ActiveRecord::Migration
  def up
    remove_column :projects, :oda_like_id
  end

  def down
    add_column :projects, :oda_like_id, :integer
  end
end
