class AddUserSuggestionEmailToProject < ActiveRecord::Migration
  def change
    add_column :projects, :user_suggestion_email, :string
  end
end
