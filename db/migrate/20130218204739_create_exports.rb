class CreateExports < ActiveRecord::Migration
  def change
    create_table :exports do |t|
      t.string :email

      t.timestamps
    end
  end
end
