module OrganizationsHelper

	def organizations_hash
		Rails.cache.fetch('global/organizations', expires_in: 10.minutes) do 
			Organization.all.map {|o| { id: o.id, name: o.name_with_type } }
		end		
	end

	def destroy_organizations_hash
		Rails.cache.delete('global/organizations')
	end
end
