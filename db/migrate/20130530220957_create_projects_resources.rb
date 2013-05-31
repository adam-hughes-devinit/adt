class CreateProjectsResources < ActiveRecord::Migration
  def change
  	
  	create_table :projects_resources do |t|
  		t.integer :project_id
  		t.integer :resource_id
  	end

  end
end
