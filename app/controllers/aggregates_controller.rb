class AggregatesController < ApplicationController
	include AggregatesHelper
	include AggregateValidators	

	skip_before_filter :signed_in_user  

	def projects

		get = params[:get]
		
		(get = get.split(",")) if get.is_a? String

		where = {}
		AggregateValidators::WHERE_FILTERS.each do |wf|
			if values = params[wf[:sym]]
				(values = values.split(VALUE_DELIMITER)) if values.is_a? String
				where[wf[:sym]] = values
			end
		end

		duplication_handler = AggregateValidators::DUPLICATION_HANDLERS.select { |h| h[:external] == "#{params[:multiple_recipients]}" }[0] || DUPLICATION_HANDLERS[0] 
		
		@aggregate = AggregateFlow.new(get: get, where: where, duplication_handler: duplication_handler)


		respond_to do |format|
			# default: render json
			format.json { render json: @aggregate.to_json }
			# if asking for CSV, send an on-the-fly CSV
			format.csv { send_data @aggregate.to_csv, filename: "AidData_China_Aggregates_#{Time.now.strftime("%y-%m-%d-%H:%M:%S.%L")}.csv"}
		end
	end
end
