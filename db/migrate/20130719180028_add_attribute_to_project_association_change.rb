class AddAttributeToProjectAssociationChange < ActiveRecord::Migration
  def change
    add_column :project_association_changes, :attribute_name, :string
  end
end
