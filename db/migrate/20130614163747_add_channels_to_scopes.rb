class AddChannelsToScopes < ActiveRecord::Migration
  def change
    add_column :scopes, :channels, :text
  end
end
