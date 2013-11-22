class CreateMediaSourceTypes < ActiveRecord::Migration
  def change
    create_table :media_source_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
