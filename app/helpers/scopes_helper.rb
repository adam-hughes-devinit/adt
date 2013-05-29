module ScopesHelper

	def scopes_hash 
	   	Rails.cache.fetch("global/scopes") do
	      Scope.all.map{ |s| s.as_json }
	    end
	end


	def remake_scopes_hash
		p "Remaking scopes hash at #{Time.new}"
		Rails.cache.delete("global/scopes")
		scopes_hash
	end

end
