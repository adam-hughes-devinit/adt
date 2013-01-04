namespace :sectors do
	desc "Add random colors"
	task :add_random_colors => :environment do
		p "Adding random colors to sectors which don't already have colors..."
		p ""
		Sector.all.each do |s| 
			if s.color.blank?
				s.update_attribute :color, "##{(color = "%06x" % (rand * 0xffffff))}"
			end
			p "#{s.name}: #{s.color}"
		end
	end
end

namespace :sectors do
	desc "Remove all colors"
	task :remove_all_colors => :environment do
		
		p "Removing colors from all sectors. Here are the old ones, just in case:"
		
		Sector.all.each do |s| 
			p "#{s.name} : #{s.color}"
			s.update_attribute :color, nil
		end
		
	end
end
