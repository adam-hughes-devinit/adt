class CreateHomepageMediaItems < ActiveRecord::Migration
  def change
    create_table :homepage_media_items do |t|
      t.string :banner_text
      t.string :banner_link
      t.string :url
      t.integer :order
      t.boolean :published

      t.timestamps
    end
  end
end
