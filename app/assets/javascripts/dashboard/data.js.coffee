
@App = @App || {}

App.initialized = () ->
	# returns "Is the app loaded?" from html state
	if $('.current_x_axis')[0]
		initialized = true
	else 
		initialized = false
	initialized

App.initialize = (csv) ->
	console.log "pulling from csv"
	
	window.d3.csv(csv, (data) ->
		console.log("processing CSV")
		
		if App.config.data.preprocessing_function
			data = App.config.data.preprocessing_function(data)

		App.projects = dv.table()
		
		App.config.data.columns.forEach((c) ->
			App.projects
				.addColumn(
					# These are defined in config.coffee
					c.name, 
					c.values_function(data), 
					c.dv_type
					)
			)

		$('#waiting').remove()

		App.svg = d3.select("#vis").append('svg')
				.attr("height", App.config.vis_height)
				.attr("width", App.config.vis_width)


		App.config.data.columns.forEach((d,i) ->
			if d.interface_type == "filter"
				make_filter_selectors(d.name, App.projects[i].lut)
			)

		$('#filter_container .accordion-body').addClass("in")

		$('.filter_box').on('keyup', filter_these_options)

		Finch.observe (params) ->
			remove_blanks = params('remove_blanks')
			console.log "URL remove blanks? ", remove_blanks
			if remove_blanks == 'true'
				App.set_remove_blanks(true)
			else
				App.set_remove_blanks(false)

			filters = App.config.data.columns.map((d) -> d.name )

			console.log 'Finch observing filters:', filters
			filters.forEach (f) ->
				if value_string = params(f)
					console.log f, value_string
					value_string.split(App.config.param_joiner).forEach (v) ->
						console.log(v)
						App.set_filter(f, v, "active")

			App.render_dashboard_from_url_state()

		if !App.current_x_axis()
			console.log "no x-axis given"
			$('.x_axis_controller').first().addClass("current_x_axis")
		
		App.render_dashboard_from_url_state()
	)


make_filter_selectors = (column_name, values, default_active = "inactive") ->


	$('#filter_container').append(
			"<div class='accordion-group span3'>

				<div class='accordion-heading'>
					<span class='accordion-toggle' data-toggle='collapse' data-parent='#filter_container' >
						Filter by #{column_name}:
					</span>
				</div>

 				<div id='collapse_#{column_name}' class='accordion-body collapse'>
					<div class='accordion-inner' id='#{column_name}_accordion'>
						<div class='controls'>
							</div>
						<div class='filters'>
						</div>
					</div>
				</div>

			</div>")
		# "<table class='filters  table-hover span3' id='#{column_name}_filters'></table>"

	target = "##{column_name}_accordion"

	$("#{target} .controls").append(
		"
		<div class='row-fluid'>
			<a class='controller x_axis_controller btn span12' data-column-name='#{column_name}' href='#/#{column_name}'>
					Set this on X-axis
			</a>
		</div>
		<div class='row-fluid'>
			<span class='controller btn deactivator span6' onclick='App.set_all_filters(\"inactive\", \"#{column_name}\")'>
				Remove All
			</span>
			<span class='controller btn activator span6' onclick='App.set_all_filters(\"active\", \"#{column_name}\", true)'>
				Select Visible 
			</span>
		</div>
		<div class='row-fluid'>
			<span> 
				<input type='text' class='filter_box span12' value='Type to filter...' onfocus='this.value=\"\"'>
			</span>")

	values.forEach((value,i) ->
		$("#{target} .filters").append(
			"<span 
				data-searcher='#{value.toLowerCase()}' 
				data-value='#{value}' 
				data-column='#{column_name}'
				class='#{column_name} controller #{default_active} value'
				onclick='App.toggle_filter(this)'
			>
				#{value}
			</span>")
	)


filter_these_options = (e) ->
	# console.log "e: ", e, "this: ", this
	entry = e.target.value.toLowerCase()
	# console.log(entry)
	rows = $(e.target).closest('.accordion-group').find('.value')
	
	if entry.length > 0
		# console.log rows
		rows.each((i,d) ->
			if entry == $(d).attr("data-searcher").substr(0, entry.length)
				$(d).css("display", "inherit")
			else 
				$(d).css("display", "none")
			)
	else 
		rows.css("display", "inherit")

App.scale_y_to_fit = (bar_data) ->
	# console.log "scale_y_to_fit", bar_data
	$('#rescale').removeClass("btn-warning").addClass("btn-primary")

	amount_domain = [
		0, 
		d3.max(bar_data.map((d) -> d.value))
		]

	cfg = App.config
	App.amount_scale = d3.scale.linear()
		.domain(amount_domain)
		.range([cfg.vis_height - cfg.vis_padding_top - cfg.vis_padding_bottom, 5])
		#.exponent(.5)

	y_axis = d3.svg.axis()
		.scale(App.amount_scale)
		.orient('right')
		 .tickFormat((amount) ->
				if 100 > amount 
					"#{d3.format("0,r")(d3.round(amount,0))}"
				else if 1000000 > amount >= 1000
					"#{d3.round((amount/1000),0)}K"
				else if 1000000000 > amount >= 1000000
					"#{d3.round((amount/1000000),1)}M"
				else if amount >= 1000000000
					"#{d3.format("0,r")(d3.round((amount/1000000000),2))}B")
		.ticks(4)

	App.amount_color_scale = d3.scale.linear()
		.domain([
			amount_domain[0],
			amount_domain[1]/2,
			amount_domain[1] * 1.1
			])
		.range(['blue', 'purple', 'red'])

	amount_axis = App.svg.selectAll('.amount_axis')
		.data([bar_data])

	amount_axis
		.enter().append('g')
		.attr('class', 'amount_axis')
		.attr('transform', "translate(10, #{cfg.vis_padding_top})")

	amount_axis	
		.call(y_axis)


