
display = (html) -> $("#header").html(html)



@csv_test = () ->
	display "Loading data..."
	path = "/projects.csv?" + $('#path').val()
	d3.csv(path, (data) ->

		console.log window.csv_data = data

		display "Loaded #{data.length} projects, see <a href='#{path.replace(/\.csv/, '') }'>search results</a>
			or <a href='#{path}'>download.</a>"
		
		console.log token = data[0]



		row_stats = {}

		

		for k, v of token
			this_array = _.pluck(data, k)
			length_of_values = ( (d || "").length for d in this_array)
			row_stats[k] = 
				"unique_count" : _.uniq(this_array).length
				"unique_values" : _.uniq(this_array)
				"populated_count" : _.without(this_array, "", null).length 
				"empty_count" : this_array.length -  _.without(this_array, "", null).length 
				"average_length" : Math.round((
						d3.mean(length_of_values)
						)*100) / 100
				"max_length" : _.max(length_of_values)
				"max_value"  : '' 
				"min_length" : _.min(length_of_values)

		
		$("#data").html("")
		$('#data').append("
			<tr>
				<td>#{k}</td>
				<td>#{v["unique_count"]}</td>
				<td>#{v["populated_count"]}</td>
				<td>#{v["empty_count"]}</td>
				<td>#{v["min_length"]}</td>
				<td>#{v["average_length"]}</td>
				<td>#{v["max_length"]}</td>
			</tr>") for k,v of row_stats


		window.ApplySortability()
		)

csv_test()
