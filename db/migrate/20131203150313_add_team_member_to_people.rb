class AddTeamMemberToPeople < ActiveRecord::Migration
  def change
    add_column :people, :current_team_member, :boolean
  end
end
