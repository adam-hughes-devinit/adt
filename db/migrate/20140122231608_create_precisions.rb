class CreatePrecisions < ActiveRecord::Migration
  def change
    create_table :precisions do |t|
      t.decimal :code
      t.string :info

      t.timestamps
    end
  end
end
