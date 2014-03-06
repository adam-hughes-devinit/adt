class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.string :name
      t.string :url
      t.string :image_url
      t.string :publisher
      t.date :date
      t.text :teaser
      t.integer :media_type_id

      t.timestamps
    end
  end
end
