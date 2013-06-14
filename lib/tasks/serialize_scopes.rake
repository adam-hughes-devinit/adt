namespace :scopes do
	desc "Define scopes in serialized :channels"
	task :serialize! => :environment do

		progress_bar = ProgressBar.new((Scope.count) * 2)

		p "Migrating scopes"
		Scope.all.each do |scope|

			serialized_data = scope.serialized_channels
			scope.channels = serialized_data
			scope.save!
			progress_bar.increment!
		end

		p "Double-checking"
		Scope.all.each do |scope|

			old_serialized_data = scope.serialized_channels
			new_serialized_data = scope.channels

			unless old_serialized_data = new_serialized_data
				raise RuntimeError, "Scope #{scope.name} didn't serialize properly. \n #{new_serialized_data.inspect } \n #{old_serialized_data}"
			end

			progress_bar.increment!
		end
			



	end

end
