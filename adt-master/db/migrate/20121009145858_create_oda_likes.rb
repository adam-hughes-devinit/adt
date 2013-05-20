class CreateOdaLikes < ActiveRecord::Migration
  def change
    create_table :oda_likes do |t|
      t.string :name

      t.timestamps
    end
  end
end
