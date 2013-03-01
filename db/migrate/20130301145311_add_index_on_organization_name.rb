class AddIndexOnOrganizationName < ActiveRecord::Migration
  def change
  	add_index :organizations, :name
  end

end
