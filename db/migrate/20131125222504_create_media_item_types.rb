class CreateMediaItemTypes < ActiveRecord::Migration
  def change
    create_table :media_item_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
