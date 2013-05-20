class AddArModelToReviewEntries < ActiveRecord::Migration
  def change
    add_column :review_entries, :ar_model, :string
  end
end
