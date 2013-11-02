class RemoveNameFromExchangeRates < ActiveRecord::Migration
  def up
    remove_column :exchange_rates, :currency_id
  end

  def down
    add_column :exchange_rates, :currency_id, :integer
    add_index  :exchange_rates, :currency_id
  end
end
