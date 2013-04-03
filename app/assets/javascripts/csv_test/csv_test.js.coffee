
display = (html) -> $("#header").html(html)



csv_test = () ->
	display "Loading data..."
	d3.csv("/projects.csv", (data) ->

		console.log window.csv_data = data

		display "Loaded #{data.length} projects, <a href='/project.csv'>download here.</a>"
		
		console.log token = data[0]



		unique_values = {}

		(console.log(k,v) for k,v of token)

		(unique_values[k] = { "unique" : _.uniq(_.pluck(data, k)).length, "populated" : _.without(_.pluck(data, k), "").length } for k, v of token)

		console.log unique_values

		$('#data').append("<tr><td>#{k}</td><td>#{v["unique"]}</td><td>#{v["populated"]}</td></tr>") for k,v of unique_values


		)

csv_test()
