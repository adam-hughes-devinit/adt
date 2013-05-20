class CreateVerifieds < ActiveRecord::Migration
  def change
    create_table :verifieds do |t|
      t.string :name

      t.timestamps
    end
  end
end
