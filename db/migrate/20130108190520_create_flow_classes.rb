class CreateFlowClasses < ActiveRecord::Migration
  def change
    create_table :flow_classes do |t|
      t.integer :project_id
			t.integer :oda_like_1_id
			t.integer :oda_like_2_id
			t.integer :oda_like_master_id
      t.timestamps
    end
  end
end
