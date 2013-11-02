class AddNameToExchangeRates < ActiveRecord::Migration
  def change
    add_column :exchange_rates, :from_currency_id, :integer
    add_index  :exchange_rates, :from_currency_id
    add_column :exchange_rates, :to_currency_id, :integer
    add_index  :exchange_rates, :to_currency_id
  end
end
