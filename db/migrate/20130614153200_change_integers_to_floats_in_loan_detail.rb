class ChangeIntegersToFloatsInLoanDetail < ActiveRecord::Migration
  def change
    change_column :loan_details, :maturity, :float
    change_column :loan_details, :grace_period, :float
  end

end
