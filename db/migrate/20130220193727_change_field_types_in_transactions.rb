class ChangeFieldTypesInTransactions < ActiveRecord::Migration
  def change
  	change_column :transactions, :usd_defl, :float
  	change_column :transactions, :value, :float
  end

end
