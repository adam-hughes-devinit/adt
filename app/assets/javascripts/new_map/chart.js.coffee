@App = @App || {}

App.config = 
	h: 500

App.svg = d3.select("#chart").append('svg:svg')
	.attr("height", "#{App.config.h}px")
	.attr("width", "100%")



App.display_country = (country_name) ->

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

	App.this_country_data.by_year = App.this_country_data.aggregate.groupBy("year", ["usd_2009", "count"])
	App.this_country_data.aggregate_json = App.this_country_data.by_year.toJSON()
	project_count = d3.sum(d["count"] for d in App.this_country_data.aggregate_json)
	total_amount = d3.sum(d["usd_2009"] for d in App.this_country_data.aggregate_json)

	$('.country_name').text(country_name)
	$('.country_detail').text("#{project_count} projects, $#{d3.format(',f')(total_amount)}.")

	top_projects_target = $('#project_rows')
	top_projects_target.html('')
	
	App.this_country_data.projects.fetch({
		error: () -> console.log "Couldn't get top projects"
		success: () ->
			top_projects = this.toJSON()
			console.log top_projects


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

	min_year = App.this_country_data.by_year.min("year")
	max_year = App.this_country_data.by_year.max("year")
	x_scale = d3.scale.linear()
		.domain([min_year, max_year])
		.range([
			50,
			$('#chart').width() - 50
			])
	
	x_axis = d3.svg.axis()
		.scale(x_scale)
		.tickFormat(d3.format('d'))
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
	
	show_this_year = (d) ->
		h = window.location.hash.replace(/\/\d{4}/, '')
		h += "/" + d.year
		Finch.navigate h



	bar_data = App.this_country_data.aggregate_json
	bar_margin = 10
	number_of_bars = max_year - min_year
	bar_width = (App.config.h - (bar_margin * number_of_bars))/number_of_bars
	
	$('.bar').tooltip("destroy")
	bars = App.svg.selectAll(".bar")
		.data(bar_data, (d) -> d.year )
		
	bars.enter().append('rect')
		.attr("id", (d) -> "bar-#{d.year}")
		.attr("class", "bar")

		.attr("data-html", true)
		.attr("data-container", "body")
		.style("cursor", "pointer")
		.style("opacity", "0")	
		.on("click", show_this_year)	

	bars.exit().remove()

	bars.transition()
			.delay((d,i) -> i*10 )
			.duration(500)
			.attr("x", (d,i) -> "#{ x_scale(d.year) }px")
			.attr("y", (d) -> "#{ y_scale(d.usd_2009) }px" )
			.attr("width", bar_width + 'px' )
			.attr("height", (d) -> "#{ 450 - y_scale(d.usd_2009) }px" )
			.style("opacity", "1")
			.style("fill", (d) -> color_scale(d.usd_2009) )
	
	bars.each (d, i) -> 
		$(this).attr("title", "To <b>#{country_name}</b> in <b>#{d.year}</b>: <br> 
					$#{nice_money(d.usd_2009)}, #{d.count} project#{( if d.count > 1 then "s" else "" )} <br>
					<em>Click for detail</em>")
	
	$('.bar').tooltip()	



	line_json = App.this_country_data.aggregate.toJSON()
	sectors = _.uniq(d["crs_sector_name"] for d in line_json)
	console.log sectors


App.details_for = (country_name, year) ->
	projects = new Miso.Dataset({
		url: "/projects.json
			?order_by=usd_2009
			&dir=desc
			&active_string=Active
			&year=#{year}
			&country_name=#{country_name}"
		})
	template_data =
		country_name: country_name
		year: year

	modal_template = $("#details_template").html()
	new_modal = _.template(modal_template, template_data )
	$('.projects-modal').remove()
	$('body').append(new_modal)
	$('.projects-modal').modal('show')	

	projects.fetch
		success: ->
			projects = this.toJSON()
			projects_template = $("#projects_template").html()
			projects_table = _.template(projects_template, {projects: projects})
			$("#projects-details").html(projects_table)
			
