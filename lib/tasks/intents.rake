namespace :projects do
	desc "Create intents"
	task :create_intents => :environment do
	
	["Development", "Commercial", "Representational", "Mixed"].each do |n|
		Intent.create!(name: n)
	end
		

	end
end

