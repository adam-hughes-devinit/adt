@App = @App || {}

App.svg = d3.select("#chart").append('svg:svg')
	.attr("height", "500px")
	.attr("width", "100%")


App.display_country = (country_name) ->
	$('.country_name').text(country_name)

	App.this_country_data = 
		aggregate: App.data.full.where(
			rows: (row) -> row.recipient_name == country_name
		)
		projects: new Miso.Dataset({
			url: "/projects.json
				?order_by=usd_2009
				&dir=desc
				&active_string=Active
				&max=10
				&country_name=#{country_name}"
			})

	App.this_country_data.by_year = App.this_country_data.aggregate.groupBy("year", ["usd_2009"])
	App.this_country_data.aggregate_json = App.this_country_data.by_year.toJSON()

	App.this_country_data.projects.fetch({
		error: () -> console.log "Couldn't get top projects"
		success: () ->
			top_projects = this.toJSON()
			console.log top_projects

			top_projects_target = $('#project_rows')
			top_projects_target.html('')
			( top_projects_target.append(
					_.template(
						$("#project_template").html()
						, p
					)
				) for p in top_projects)

			# bootstrap-sortable
			ApplySortability()
		})


	color_scale = d3.scale.linear()
		.domain([
			App.this_country_data.by_year.max("usd_2009") * 1.1,
			App.this_country_data.by_year.min("usd_2009") 
			])
		.range([
			"red",
			"blue"
			])

	y_scale = d3.scale.linear()
		.domain([
			App.this_country_data.by_year.max("usd_2009") * 1.1,
			App.this_country_data.by_year.min("usd_2009") 
			])
		.range([50, 450])

	y_axis = d3.svg.axis()
		.scale(y_scale)
		.orient('right')
		.tickFormat(nice_money)
		.ticks(4)

	y_axis_svg = App.svg.selectAll('.y_axis')
		.data(App.this_country_data.aggregate_json)
	
	y_axis_svg
		.exit().remove()

	y_axis_svg
		.enter().append('g')
		.attr('class', 'y_axis')
		.attr('transform', "translate(10, 10)")

	y_axis_svg
		.call(y_axis)


	x_scale = d3.scale.linear()
		.domain([
			App.this_country_data.by_year.min("year"),
			App.this_country_data.by_year.max("year")
			])
		.range([
			50,
			$('#chart').width() - 50
			])
	
	x_axis = d3.svg.axis()
		.scale(x_scale)
		.tickFormat((d) -> d)
		.orient('bottom')

	x_axis_svg = App.svg.selectAll('.x_axis')
		.data(App.this_country_data.aggregate_json)

	x_axis_svg
		.exit().remove()

	x_axis_svg
		.enter().append('g')
		.attr('class', 'x_axis')
		.attr('transform', "translate(10, 450)")

	x_axis_svg
		.call(x_axis)

	bars = App.svg.selectAll(".bar")
		.data(App.this_country_data.aggregate_json, (d) -> d.year )
		
	bars.enter().append('rect')
		.attr("class", "bar")
		.style("cursor", "pointer")

	bars.exit().remove()

	bars.transition()
			.delay((d,i) -> i*10 )
			.attr("x", (d,i) -> "#{ x_scale(d.year) }px")
			.attr("y", (d) -> "#{ y_scale(d.usd_2009) }px" )
			.attr("width", '20px' )
			.attr("height", (d) -> "#{ 450 - y_scale(d.usd_2009) }px" )
			.style("fill", (d) -> color_scale(d.usd_2009) )