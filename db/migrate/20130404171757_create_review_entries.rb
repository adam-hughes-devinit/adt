class CreateReviewEntries < ActiveRecord::Migration
  def change
    create_table :review_entries do |t|
      t.string :status, default: "OPEN"
      t.text :serialized_item

      t.timestamps
    end
  end
end
