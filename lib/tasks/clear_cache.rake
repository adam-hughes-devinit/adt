namespace :caches do
	desc "Wipe everything"
	task :wipe => :environment do
		Rails.cache.clear
		ActionController::Base.new.expire_fragment %r{.*}

	end
end

