class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.decimal :value
      t.integer :currency_id
      t.decimal :usd_defl
      t.integer :project_id

      t.timestamps
    end
  end
end
