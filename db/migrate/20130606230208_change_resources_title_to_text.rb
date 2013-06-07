class ChangeResourcesTitleToText < ActiveRecord::Migration
  def change
  	change_column :resources, :title, :text
  end
end
