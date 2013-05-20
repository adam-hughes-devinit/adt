class RenameAndChangeTypeOfFlagTypeColumn < ActiveRecord::Migration
  def change
  	change_column :flags, :flag_type, :integer
  	rename_column :flags, :flag_type, :flag_type_id
  end

end
