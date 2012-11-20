class Cache < ActiveRecord::Base
  attr_accessible :id, :text
  after_save :update_complete_cache
  
  def update_complete_cache
  	if CACHE_ALL and id!=0
  		Cache.find_or_create_by_id(0).update_attribute(:text, Cache.all.map(&:text).join("
")) 
		end
	end
end
