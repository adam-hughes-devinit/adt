class MakeMoreResourceColumnsIntoText < ActiveRecord::Migration
  def change
  	change_column :resources, :publisher, :text
  	change_column :resources, :publisher_location, :text
  end
end
