module Typeaheadable

   # Logic for twitter typeahead.  This is used for the site search bar.
	def enable_typeahead(active_record_model, options={})
		# pass facets: {facet: value, facet: value}
		facets = options[:facets] || []
		max = options[:max] || 15

		raise NoMethodError, "Model must be searchable" unless active_record_model.respond_to?(:search)

		define_method "twitter_typeahead" do
      #search = active_record_model.search do
			search = active_record_model.solr_search do
				fulltext params[:search]
				facets.each{ |k,v| with k,v  }
				paginate page: 1, per_page: max
			end

      models = search.results

			if models.length > 0
				model_name = models.first.class.name
				raise NoMethodError, "#{model_name} must respond to :to_english" unless models.first.respond_to?(:to_english)


				typeahead_array = models.map do |model|

					value_method = options[:value_method] || :id
					typeahead_object = {
						value: model.send(value_method),
						tokens: model.to_english.split(" "),
						english: model.to_english,
						type: model_name,
						target: (model_name == 'Content' ? content_by_name_path(model.name) : url_for(model))
					}
				end
			else
				typeahead_array = []
			end



			render json: typeahead_array
		end
	end

end
