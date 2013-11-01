class CreateExchangeRates < ActiveRecord::Migration
  def change
    create_table :exchange_rates do |t|
      t.float :rate
      t.integer :year
      t.references :currency

      t.timestamps
    end
    add_index :exchange_rates, :currency_id
  end
end
