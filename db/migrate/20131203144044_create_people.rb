class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.references :position
      t.string :first_name
      t.string :last_name
      t.string :title
      t.text :bio
      t.string :email

      t.timestamps
    end
    add_index :people, :position_id
  end
end
