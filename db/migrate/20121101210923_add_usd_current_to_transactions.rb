class AddUsdCurrentToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :usd_current, :float
  end
end
