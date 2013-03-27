# This lays the groundwork for 
# 1) collecting params from the inputs
# 2) sending params to the API
# 3) using the response to populate the map

v = window.vis_config

gather_inputs = () ->
	oda_likes = []
	$('#oda_like_input option:selected').each((d) ->
		t = $(this).text(); 
		if (t.indexOf('All') != 0) 
			oda_likes.push(t)
			)
	verifieds = []
	$('#verified_input option:selected').each((d) ->
		t = $(this).text(); 
		if (t.indexOf('All')!=0) 
			verifieds.push(t)
			)
	sectors = []
	$('#sector_input option:selected').each((d) ->
		t = $(this).text(); 
		if (t.indexOf('All')!=0) 
			sectors.push(t)
			)
	flow_types = []
	$('#flow_type_input option:selected').each((d) -> 
		t = $(this).text(); 
		if t.indexOf('All')!=0
			flow_types.push(t)
			)
	active_years = [] # years was already taken
	$('#year_input option:selected').each((d) -> 
		t = $(this).text(); 
		if (t.indexOf('All')!=0) 
			active_years.push(t)
			)
	input_params = {}

	if oda_likes.length > 0 
		input_params.flow_class = oda_likes
	if verifieds.length > 0 
		input_params.verified = verifieds
	if sectors.length > 0 
		# UPDATE FOR CRS SECTORS 
		input_params.crs_sector_name = sectors
	if flow_types.length > 0 
		input_params.flow_type = flow_types 
	if active_years?.length > 0
		input_params.year = active_years
		v.years = active_years

	#console.log('input_params', input_params)
	delete window.active_params.recipient_iso2
	delete window.active_params.get
	if input_params != @active_params 
		input_params
	else 
		null

send_params = (params) ->
	# fuzz_and_remove_mouse_listeners()
	#
	# I'm leaving this off... a different feeling!
	#
	post_params = params ? {}
	post_params.get = "recipient_iso2"
	post_params.multiple_recipients = "percent_then_merge"
	$.post('/aggregates/projects', post_params, color_the_map, "json")

color_the_map = (json) ->
	# Edit this duration or delay to
	# Change the speed of the update animation
	# It's abstracted bc it's used to calculate the unfuzz time
	item_duration = 200
	item_delay = 10
	window.map_data.forEach((d,i) ->
		# For each map_data, find the json that goes with it
		if (n = json.filter((j)->j.recipient_iso2 == d.key)[0]) 
			# If you find a match, update the map_data
			d.values.value = n.usd_2009
			d.values.value_current = n.usd_current	
		else
			d.values.value = null
			d.values.value_current = null) 
	# Then update the color scale with your new data
	window.vis_config.c.domain([0,
		((d3.max(window.map_data, (m) -> Number(m.values.value)))/4),
		(d3.max(window.map_data, (m) -> Number(m.values.value))*1.1)
		]);
	# Then iterate over map_data to recolor the svg elements
	window.map_data.forEach((d,i) ->
		country = d3.select("#"+d.key)
		if d.values.value == null 
			color = '#777' 
		else 
			color =  window.vis_config.c(d.values.value)
		country.transition()
			.duration(item_duration)
			.delay(i*item_delay)
			.attr('fill', color)
		)
	window.total_amount_in_view = d3.sum(window.map_data,(m) -> m.values.value )
	unfuzz_and_add_mouse_listeners((item_delay*window.map_data.length)+item_duration,item_duration)
	make_a_legend()

make_a_legend = () ->
	#console.log "making legend"
	w = window.vis_config.w
	h = window.vis_config.h
	c = window.vis_config.c
	legend_bar_width = (18/800)*w
	legend_bar_margin = 2
	min_bar_height = (1/10)*h
	bar_height_increment = (2/80)*h
	legend_font_size = 10
	max_bar_height = min_bar_height + (bar_height_increment * 3)
	
	amounts = c.domain()
	max = Math.max(amounts[2], 1000000)
	# legendize = (v) -> Math.round()
	legend_amounts = [max/10, max/5, max/2, (max*1.1)]
	#console.log(legend_amounts)
	d3.selectAll('.legend_bar, .legend_text')
		.transition()
			.duration(400)
			.style("font-size", "0px")
			.attr("width", "0px")
			.remove()

	legend = d3.select('#africa-map').selectAll('#id')
		.data([legend_amounts])
		.enter().append('g')
			.attr("id", "legend")
			.attr("transform", "translate("+(w/12)+","+((5.5/8)*h)+")")

	legend.selectAll('.legend_bar')
		.data(Object)
		.enter().append('rect')
			.attr("x", "0")
			.attr("y", (d,i) -> (max_bar_height - (i*bar_height_increment)))
			.attr("height", legend_bar_width)
			.attr("width", "0px")
			.attr("fill", (d) -> c(d) )
			.attr('class', 'legend_bar')
			.transition()
				.duration(800)
				.attr("width", (d,i) -> "#{((i/4)*100)+50}px")

	legend.selectAll('.legend_text')
		.data(Object)
		.enter().append('text')
			.attr("x", "5px")
			.attr("y", (d,i) -> (2 + legend_font_size + max_bar_height - (i*bar_height_increment)))
			.style("font-size", legend_font_size)
			.attr("fill", (d,i) -> "#{window.vis_config.grayscalec(i)}")
			.text((d) -> "$#{window.vis_config.nicemoneyaxis(d.toFixed())}")
			.attr('class', 'legend_text')
			.style("opacity", "0")
			.transition()
				.duration(800)
				.style("opacity", "1")
	
	legend.append("svg:foreignObject")
		.attr("height", "100")
		.attr("width", "300")
		.attr("y", max_bar_height+bar_height_increment)
		.attr("x", "-20px")
		.append("xhtml:body")
			.style("padding-top", "0px")
			.style("background-color", "transparent")
			.html("<p style='color:black;'>" + 
				"<b>Chinese Development Finance, 2000-2011<b><br><i>USD-2009</i> || <a style='color:#333;'href='/projects'>See the Data</a></p>")

unfuzz_and_add_mouse_listeners = (delay, duration) ->
	d3.selectAll('.fuzz')
		.transition()
		.delay(delay ? 100)
		.duration(duration ? 100)
		.attr("filter", "")
		.each("end", ()->
			country = d3.select(this)
			data_item = map_data_item(this.id)
			if data_item?.values.value > 0 
				country
					.on("click", click)
					.on("mouseover", highlight)
					.on("mouseout", unhighlight)
					.style('cursor', 'pointer')

			else 
				country
					.on("click", "")
					.on("mouseover", highlightnull)
					.on("mouseout", unhighlight)
					.style('cursor', '')
					.transition()
					.attr("fill",  "#777")
		)	
unhighlight = () ->
	d3.select(this)
		.transition()
		.attr("stroke",() -> 
			if $(this).attr("name") && $(this).attr("id")!="non_african"
				"#333" 
			else
				"" 
		)	
	$('#tooltip').hide()
	$('#tooltiptext').text("")

highlightnull = () ->
	# get the country info
	active_name = $(this).attr("name")
	#show and write the tooltip
	$('#tooltip').show()
	$('#tooltiptext').html("#{active_name}<br>No active projects")

highlight = () ->
	d3.select(this)
		.transition()
		.attr("stroke", "#ddd")   
	# get the country info
	active_iso = this.id
	active_name = $(this).attr("name")
	#show and write the tooltip
	$('#tooltip').show()
	$('#tooltiptext').html("#{active_name}<br>" +
		"Total: $#{window.vis_config.nicemoney(window.map_data_item(active_iso).values.value)}")

window.vis_config.gather_inputs = gather_inputs


$('.vis_input').change(() -> 
	#console.log 'triggered new params'
	$('.overlay').remove()
	
	if params = gather_inputs()
		window.active_params = params
		#console.log('active_params', window.active_params)
		send_params(params)
)


$(document).mousemove((event) ->
	mousePosition = {left: event.pageX, top: event.pageY}
	$('div#tooltip').css('left',mousePosition.left+10)
	$('div#tooltip').css('top',mousePosition.top-25))

send_params()






