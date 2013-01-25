class RenameInterestColumn < ActiveRecord::Migration
  def change
  	rename_column :loan_details, :instrest_rate, :interest_rate
  end

end

