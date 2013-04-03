class DropCachesTable < ActiveRecord::Migration
  def change
  	drop_table :caches
  end
end
