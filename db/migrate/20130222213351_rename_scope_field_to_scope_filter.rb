class RenameScopeFieldToScopeFilter < ActiveRecord::Migration
  def change
  	rename_column :scope_filter_values, :scope_field_id, :scope_filter_id
  end


end
