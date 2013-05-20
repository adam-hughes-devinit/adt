class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title
      t.text :description
      t.date :start_planned
      t.date :start_actual
      t.date :end_planned
      t.date :end_actual
      t.integer :year
      t.string :capacity
      t.integer :flow_type_id
      t.integer :sector_id
      t.string :sector_comment
      t.integer :tied_id
      t.integer :oda_like_id
      t.integer :status_id
      t.integer :verified_id
      t.integer :donor_id
      t.boolean :is_commercial, default: false
      t.boolean :active, default: true
      t.integer :owner_id
      t.integer :media_id

      t.timestamps
    end
  end
end
