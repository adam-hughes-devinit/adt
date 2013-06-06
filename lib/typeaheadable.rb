module Typeaheadable

	def enable_typeahead(active_record_model, options={})
		# pass facets: {facet: value, facet: value}
		facets = options[:facets] || []

		raise NoMethodError, "Model must be searchable" unless active_record_model.respond_to?(:search)
		
		define_method "twitter_typeahead" do
			search = active_record_model.search do
				fulltext params[:search]
				facets.each{ |k,v| with k,v  }

				
				paginate page: 1, per_page: 15
			end

			models = search.results


			raise NoMethodError, "Model must respond to :to_english" unless models.first.respond_to?(:to_english)
			model_name = models.first.class.name

			typeahead_array = models.map do |model|

				typeahead_object = {
					value: model.id,
					tokens: model.to_english.split(" "),
					english: model.to_english,
					type: model_name,
					target: url_for(model)
				}
			end


			render json: typeahead_array
		end
	end

end
