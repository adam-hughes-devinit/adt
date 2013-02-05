module ProjectCache
  include ProjectExporters

	def cache!
		if CACHE_ONE
			cached_record = Cache.find_or_create_by_id(id)
			cached_record.skip_cache_all = false
			cached_record.update_attribute(:text, self.csv_text)
		end
	end
	handle_asynchronously :cache!
	
	def cache_one!
		if CACHE_ONE
			cached_record = Cache.find_or_create_by_id(id)
			cached_record.skip_cache_all = true
			cached_record.update_attribute(:text, self.csv_text)
		end
	end
	handle_asynchronously :cache_one!
end
