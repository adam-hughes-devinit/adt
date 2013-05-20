class AddTimeCalculatedToLoanDetails < ActiveRecord::Migration
  def change
    add_column :loan_details, :time_calculated, :datetime
  end
end
