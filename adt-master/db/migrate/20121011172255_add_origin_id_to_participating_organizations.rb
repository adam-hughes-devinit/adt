class AddOriginIdToParticipatingOrganizations < ActiveRecord::Migration
  def change
  	add_column :participating_organizations, :origin_id, :integer
  end
end
