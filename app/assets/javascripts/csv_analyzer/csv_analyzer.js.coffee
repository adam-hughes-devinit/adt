
display = (html) -> $("#header").html(html)



@csv_test = () ->
	display "Loading data..."
	path = "/projects.csv?" + $('#path').val()
	d3.csv(path, (data) ->

		
		window.csv_data = data

		display "Loaded #{data.length} projects, see <a href='#{path.replace(/\.csv/, '') }'>search results</a>
			or <a href='#{path}'>download.</a>"
		
		console.log token = data[0]

		half_the_data = data.length / 2.0


		window.row_stats = {}

		

		for k, v of token
			this_array = _.pluck(data, k)

			populated_count = _.without(this_array, "", null).length 
			unique_values = _.uniq(this_array)
			length_of_values = ( (d || "").length for d in this_array)
			max_length =  _.max(length_of_values)
			min_length =  _.min(length_of_values)

			row_stats[k] = 
				"unique" :
					"count"  : unique_values.length
					"values" : unique_values
				"populated":
					"count"  : populated_count
					"values" : (d["project_id"] for d in data when (d[k] isnt null and d[k] isnt ""))
				"empty" :
					"count"  : this_array.length -  populated_count
					"values" : (d["project_id"] for d in data when (d[k] is null or d[k] is ""))
				"average" :
					"length" : Math.round((
						d3.mean(length_of_values)
						)*100) / 100
				"max":
					"length" : max_length
					"value"  : _.find(this_array, (d) -> d.length is max_length)
				"min":
					"length" : min_length
					"value"  : _.find(this_array, (d) -> d.length is min_length)

		
		$("#data").html("")
		#
		# VV WHITE SPACES MESS WITH SORTING
		#
		$('#data').append("
			<tr>
				<td>#{k}</td>
				<td>" +
					"<a class='csv-tooltip' href='#'title='#{v["unique"]["values"].join(" | ").replace(/'/g, '')}'>" +
						"#{v["unique"]["count"]}"+
					"</a>" +
				"</td>
				<td>" +
					"<a class='csv-tooltip' href='#'title='#{v["populated"]["values"].join(" | ").replace(/'/g, '')}'>" +
						"#{v["populated"]["count"]}"+
					"</a>" +
				"</td>
				<td>" +
					"<a class='csv-tooltip' href='#'title='#{v["empty"]["values"].join(" | ").replace(/'/g, '')}'>" +
						"#{v["empty"]["count"]}"+
					"</a>" +
				"</td>
				<td>" +
					"<a class='csv-tooltip' href='#' title='#{v["min"]["value"].replace(/'/g, '')}' >#{v["min"]["length"]}</a>" +
				"</td>
				<td>"+
					"<!-- a class='csv-tooltip' href='#' title='' !-->#{v["average"]["length"]}</a>" +
				"</td><td>" +
					"<a class='csv-tooltip' href='#' title='#{v["max"]["value"].replace(/'/g, '')}' >#{v["max"]["length"]}</a>" +
				"</td>
			</tr>") for k,v of row_stats

		$('.csv-tooltip').tooltip()
		window.ApplySortability()
		)


csv_test()
