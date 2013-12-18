class RemoveLinksFromHomepageMediaItem < ActiveRecord::Migration
  def up
    remove_column :homepage_media_items, :banner_link
    remove_column :homepage_media_items, :banner_link_text
  end

  def down
    add_column :homepage_media_items, :banner_link_text, :string
    add_column :homepage_media_items, :banner_link, :string
  end
end
