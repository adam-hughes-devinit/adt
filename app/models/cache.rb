class Cache < ActiveRecord::Base
  attr_accessible :id, :text
  after_save :update_complete_cache
  
  def update_complete_cache
  	if CACHE_ALL and id!=0
    	if Rails.env.production?
				update_the_whole_cache="Update caches set text=(select array_to_string(array_agg(text), '
') from caches where id !=0 ) where id=0;"
				Cache.connection.execute(update_the_whole_cache)
			else
				Cache.find_or_create_by_id(0).update_attribute(:text, Cache.all.map(&:text).join("
")) 
			end
		end
	end
end
