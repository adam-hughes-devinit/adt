namespace :projects do
	desc "Relace &amp; with &"
	task :repair_ampersand => :environment do

	c = 0
	ids = []

	Project.where("description like '%&amp;%'").each do |p|
		p.update_attribute(:description, p.description.gsub(/&amp;/, ' '))
		ids.push p.id
		c+=1
	end
		
	
	p "#{c} ampersands corrected."
	p ids
	
	end
end


namespace :projects do
	desc "Remove style definitions from description text"
	task :remove_style_definitions => :environment do

	c = 0
	ids = []
	
	Project.where("description like '%Style Definitions%'").each do |p|
		p.update_attribute(:description, p.description.gsub(/Normal  0.+}/, ' '))
		ids.push p.id
		c+=1
	end
	
	p "#{c} style definitions removed."
	p ids
	end
end

namespace :projects do
	desc "Remove PPIAF"
	task :remove_ppiaf => :environment do

	c = 0
	ids = []
	
	Project.where("description like '%PPIAF%' or title like '%PPIAF%'").each do |p|
		p.update_attribute(:description, p.description.gsub(/PPIAF/, ''))
		p.update_attribute(:title, p.title.gsub(/[\(]PPIAF(\sID\s\d+|\s-\s)[\)]/, ''))
		ids.push p.id
		c+=1
	end
	
	p "#{c} PPIAFs removed."
	p ids
	end
end

