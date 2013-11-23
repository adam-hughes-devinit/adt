class AddHomepageToMediaItem < ActiveRecord::Migration
  def change
    add_column :media_items, :on_homepage, :boolean
  end
end
