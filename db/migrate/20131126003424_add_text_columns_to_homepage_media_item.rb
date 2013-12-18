class AddTextColumnsToHomepageMediaItem < ActiveRecord::Migration
  def change
    add_column :homepage_media_items, :banner_title, :string
    add_column :homepage_media_items, :banner_link_text, :string
  end
end
