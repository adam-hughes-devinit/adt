class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :title
      t.text :authors
      t.string :publisher
      t.date :publish_date
      t.string :publisher_location
      t.datetime :fetched_at
      t.text :download_url
      t.boolean :dont_fetch
      t.string :resource_type

      t.timestamps
    end
  end
end
