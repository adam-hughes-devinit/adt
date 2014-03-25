class CreatePublications < ActiveRecord::Migration
  def change
    create_table :publications do |t|
      t.integer :publication_type_id
      t.string :name
      t.string :author
      t.string :url
      t.integer :date
      t.string :type
      t.string :location
      t.string :publisher
      t.text :description

      t.timestamps
    end
  end
end
