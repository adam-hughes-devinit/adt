class CreateUniversalMediaItems < ActiveRecord::Migration
  def change
    create_table :universal_media_items do |t|

      t.timestamps
    end
  end
end
