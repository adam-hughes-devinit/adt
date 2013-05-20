class AddABunchOfIndexes < ActiveRecord::Migration
  def change
  	add_index "countries", "id"
  	add_index "sectors", "id"
  	add_index "organizations", "id"
  	add_index "flow_types", "id"
  	add_index "oda_likes", "id"
  	add_index "verifieds", "id"
 	add_index "tieds", "id"
  	add_index "statuses", "id"


  	add_index "geopoliticals", "project_id"
  	add_index "sources", "project_id"
  	add_index "contacts", "project_id"
  	add_index "transactions", "project_id"
  	add_index "participating_organizations", "project_id"

  	add_index "projects", "id"


  end

end
