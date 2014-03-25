class CreatePrecisions < ActiveRecord::Migration
  def change
    create_table :precisions do |t|
      t.float :code
      t.string :description

      t.timestamps
    end
  end
end
