class CreateTieds < ActiveRecord::Migration
  def change
    create_table :tieds do |t|
      t.string :name
      t.integer :iati_code

      t.timestamps
    end
  end
end
