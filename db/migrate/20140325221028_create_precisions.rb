class CreatePrecisions < ActiveRecord::Migration
  def change
    create_table :precisions do |t|
      t.integer :code
      t.text :description

      t.timestamps
    end
  end
end
