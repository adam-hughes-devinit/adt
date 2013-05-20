class AddDeflatorAndExchangeRateAndDeflatedAtToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :deflator, :float
    add_column :transactions, :exchange_rate, :float
    add_column :transactions, :deflated_at, :timestamp
  end
end
