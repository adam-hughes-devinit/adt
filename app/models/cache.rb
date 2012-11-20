class Cache < ActiveRecord::Base
  attr_accessible :id, :text
  after_save :update_complete_cache
  
  def update_complete_cache
  	Cache.find_or_create_by_id(0).update_attribute(:text, Cache.all.map{|c| c.text}.join("
")) unless id==0 || CACHE_ALL==false
	end
end
