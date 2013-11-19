class AddFeaturedToMediaItem < ActiveRecord::Migration
  def change
    add_column :media_items, :featured, :boolean
  end
end
