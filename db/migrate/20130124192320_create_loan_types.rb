class CreateLoanTypes < ActiveRecord::Migration
  def change
    create_table :loan_types do |t|
      t.integer :id
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
