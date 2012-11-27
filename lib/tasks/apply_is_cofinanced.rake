namespace :projects do
	desc "Apply is_cofinanced variable, which was missed by import script"
	task :apply_is_cofinanced => :environment do

cofinanced_ids = [
19874,538,14795,18763,21374,
28153,304,1250,914,15093,2050,2055,20669,1407,1735,24832,868,17166,18864,1960,2140,
215,335,21334,14868,21355,1619,19641,2424,1151,15658,19300,23554,
1034,1348,16829,14303,17764,18121,18271,19906,11391,21341,149,856,1137,1174,
1649,1830,2092,21348,19884,227,14709,2459,22211,1738,1136,22279,1988]

		CACHE_ALL = false
		Project.where("id in (?)", cofinanced_ids).each{ |p| p.update_attribute :is_cofinanced, true}
		CACHE_ALL = true
		Project.first.cache!
		p "finished applying."
	end
end


namespace :projects do
	desc "Make year_uncertain=True where year is null"
	task :year_uncertain_when_null => :environment do


		CACHE_ALL = false
		Project.where("year is null").each{ |p| p.update_attribute :year_uncertain, true}
		CACHE_ALL = true
		Project.first.cache!
		p "finished applying."
	end
end


