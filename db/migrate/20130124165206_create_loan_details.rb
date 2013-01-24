class CreateLoanDetails < ActiveRecord::Migration
  def change
    create_table :loan_details do |t|
      t.integer :project_id
      t.integer :loan_type_id
      t.float :instrest_rate
      t.integer :maturity
      t.integer :grace_period
      t.float :grant_element

      t.timestamps
    end
  end
end
