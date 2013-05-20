class RemoveOldScopeTables < ActiveRecord::Migration
  def up
  	drop_table :scopes 
  	drop_table :scope_requirements
  end


end
