# the function is window.click, 
# So that it can be assigned on the past document


drop_overlay = () ->
	d3.selectAll('.fuzz')
		.transition()
			.duration(500)
			.attr("filter", "url(#blur)");  
	
	overlay = window.vis.append('svg:g')
		.attr('id', 'overlay-wrapper')
		.attr('class', 'overlay')

	dark_box = overlay.append('svg:rect')
		.attr("id", "grayBox")
		.attr('class', 'overlay')
		.attr("height", window.vis_config.h)
		.attr("width", window.vis_config.w)
		.style("fill", "black")
		.style("opacity", "0")
		.on("click", remove_overlay)

	dark_box.transition()
			.duration(600)
			.style("opacity", ".7")  

	return overlay


remove_overlay = () ->

	d3.selectAll('.overlay')
		.transition('opacity', 0)
			.delay(10)
			.duration(100)
			.remove()

	d3.selectAll('.fuzz')
		.transition()
			.duration(1000)
			.attr("filter", ""); 

get_active_country = (item) ->
	active_country =
			iso2: item.id
			name: $(item).attr("name")


make_header = (overlay, active_country) ->
	h = window.vis_config.h
	w = window.vis_config.w
	label_green = window.vis_config.label_green
	country_header = overlay.append('svg:g')
		.attr("id", "country_header")
		.append("svg:foreignObject")
			.attr("x", 120)
			.attr("y", 20)
			.attr("height", h/6)
			.attr("width", w/2.1)  
			.append('xhtml:body')
	country_header
		.attr("height", h/6)
		.attr("width", w/2.1)
		.style("padding-top","10px")
		.style("background-color", "transparent")
		.style("opacity", "1")
		.style("color", label_green.brighter())
		.style("font-size", 50)	      	 
		.style("font-family", "Georgia")		 
		.style("font-weight", "bold") 
		# style='color:#{label_green.brighter()};border-color:#{label_green.brighter()}'
		.html("<div id='country_header_body' style='line-height:40px;font-size:40px;opacity:1; "+ 
			"height:#{h/6}; width:#{w/2.1}'>
			<h1 style='color:#{label_green.brighter()};border-color:#{label_green.brighter()}' class='page-header country-header'>
				#{active_country.name}
				</h1>
				</div>")

make_pie_chart = (overlay, active_country) ->
	pie = d3.layout.pie().sort(d3.ascending)
	label_green = window.vis_config.label_green
	pie_radius = 40
	arc = d3.svg.arc().outerRadius(pie_radius)	
	percent_of_total = Math.round(
		((window.map_data.filter((d) -> 
			d.key == active_country.iso2))[0].values.value/
			window.total_amount_in_view)*1000)/10
	pie_data = [100 - percent_of_total, percent_of_total]
	
	tweenPie = (b) ->
		b.innerRadius = 0
		i = d3.interpolate({startAngle: 0, endAngle: 0}, b)
		(t) ->
			arc(i(t))
	pie_chart = overlay.append('svg:g')
		.data([pie_data])
		.attr("id", "pie_chart")
		.attr("width", pie_radius*2)
		.attr("height", pie_radius*2)
		.attr("transform", "translate(20,20)")
	arcs = pie_chart.selectAll("g.arc")
		.data(pie)
		.enter().append("g")
		.attr("class", "arc")
		.attr("transform", "translate(" + pie_radius + "," + pie_radius + ")");
	
	paths = arcs.append("path")
		.attr("fill", (d, i) -> 
			if i == 1 
				label_green.brighter() 
			else 
				'#fff')
	paths.transition()
		.duration(1000)
		.attrTween("d", tweenPie);				 
	
	pie_label = [
		{ text: "#{percent_of_total}%", size: 17}
		{ text: "of flows", size: 12}
		{ text: "on map.", size: 12}
	]

	for l, i in pie_label
		pie_chart.append("text")
			.attr("y", (pie_radius) + 2 + (i*12))
			.attr("x", (pie_radius))
			.attr("text-anchor", "middle")
			.attr("fill", label_green.darker() )
			.style("font-weight", "bold")
			.style("font-size", l.size)
			.text(l.text)

make_sector_graph = (overlay, active_country) ->
	#console.log "before sector graph years: ", window.vis_config.years
	if window.vis_config.years.length is 1
		window.vis_config.years = [(window.vis_config.years[0]-1), window.vis_config.years[0], (Number(window.vis_config.years[0])+1)]
	years = window.vis_config.years

	sectors = active_country.data.map((d) -> d.crs_sector_name).getUnique()
	
	stackLayers = []  
	sectors.forEach((sector) ->
		sectorLayer = []
		# years is defined at the top -- range 2000 to 201x
		years.forEach((year) -> 
			pointData = active_country.data.filter((d) -> 
				Number(d.year) == year && d.crs_sector_name == sector)
			point = {x: year, y: d3.sum(pointData, (d)-> d.usd_2009)}
			sectorLayer.push(point)
		)
		stackLayers.push(sectorLayer)
	)

	yearSectorStack = d3.layout.stack()(stackLayers)
	sectorSums = d3.nest() 
		.key((d) -> d.crs_sector_name)
		.rollup((data) ->{ "value" : d3.sum(data,(d) -> d.usd_2009), "count" : d3.sum(data, (d) ->d.count) } )
		.entries(active_country.data)
	# for building scales...
	annual_amounts = []
	yearSectorStack[0].forEach((d,i) ->
		annual_amount = 0
		yearSectorStack.forEach((e) ->
			annual_amount += e[i].y
			)
		annual_amounts.push(annual_amount)
	)
	annual_maximum = Math.max(Math.round(d3.max(annual_amounts)/5000000)*5000000, 10000000)
	

	h = window.vis_config.h
	w = window.vis_config.w
	sector_area_h = .4*w
	sector_area_w = .4*w
	sector_area_y = d3.scale.pow().domain([0,annual_maximum]).range([sector_area_h, 0])
	sector_area_x = d3.scale.linear().domain([d3.min(years), d3.max(years)]).range([0,sector_area_w])
	highest_label = (1/16)*h
	lowest_label = h-((1/16)*h)
	label_left_position = (4.5/8)*w
	label_height = d3.scale.linear().domain([0,sectorSums.length]).range([highest_label, lowest_label])
	label_increment = d3.min([label_height(1) - label_height(0), 35]) 

	sector_area = d3.svg.area()
		.x((d,i) -> sector_area_x(d.x))
		.y0((d) ->  sector_area_y(d.y0))
		.y1((d) ->  sector_area_y(d.y + d.y0))
		.interpolate('monotone')

	null_area = d3.svg.area()
		.x((d) ->  sector_area_x(d.x))
		.y0(sector_area_h)
		.y1(sector_area_h)
		.interpolate('monotone')

	headers = overlay.append('svg:g')
		.attr('id', 'headers')
		.append("svg:foreignObject")
			.attr("height", (label_increment * (sectorSums.length+2)) + 10)
			.attr("width", (3.5/8)*w)
			.attr("x", label_left_position-20)
			.attr("y", highest_label + 45)
			.append("xhtml:body")
				.attr('id', 'sectors_body')
				.style("padding", "5px")
				.style("background-color", "hsla(360, 0%, 100%, 0.95)")
	# get the body content, then load it
	headers_html = "
		<table style='margin:3px;font-size:#{window.vis_config.bigger_font_size}px' class='table table-hover'>
			<thead>
				<tr>
					<th>Sector</th>
					<th>Amount</th>
					<th>Projects</th>
				</tr>
			</thead>
			<tbody>"
	td_style = 'padding:2px;line-height:14px;'
	sectorSums.forEach((s) ->
		url = "/projects?active_string=Active" +
			(if current_scope.name != "All Projects" then "&scope_names[]=" + current_scope.name else "") +
			"&country_name=#{active_country.name}&crs_sector_name=#{s.key}"
		headers_html += "
			<tr>
				<td style='#{td_style}'>
					<a href='#{url}'>
					<strong style='color:#{window.vis_config.c_sector(s.key)}'>#{s.key}<strong>
					</a>
				</td>
				<td style='#{td_style}'>
					<a href='#{url}'>
						$#{window.vis_config.nicemoney(Math.round(s.values.value))}
					</a>
				</td>
				<td style='#{td_style}'>
					<a href='#{url}'>
						#{s.values.count} 
					</a>
				</td>
			</tr>")

	headers_html += "</tbody></table>"
	# load the headers 
	headers.html(headers_html)
	ApplySortability()
	# paint the area chart
	# hold it it a g
	area_chart = overlay.append('svg:g')
		.attr("id", "area_chart")
		.attr('transform', 'translate('+(.125*w)+','+(.2*h)+')')

	# paint the year labels
	xAxis = d3.svg.axis()
		.scale(sector_area_x)
		.orient('bottom')
		.tickFormat(d3.format("f")) 
		.tickValues(years)
	area_chart.append("svg:g")
		.attr('class', 'axis')
		.call(xAxis)
		.style('fill', '#ccc')
		.attr('transform', 'translate(0,'+(sector_area_h+2)+')')
		.attr("opacity", 0)

	# paint the amount labels
	yAxis = d3.svg.axis()
		.scale(sector_area_y)
		.orient('left')
		.tickFormat((d) ->  "$"+window.vis_config.nicemoneyaxis(d))
	area_chart.append("svg:g")
		.attr('class', 'axis')
		.call(yAxis)
		.style('fill', '#ccc')
		.attr("opacity", 0)

	area_chart.selectAll('.axis')
		.transition()
		.delay((d,i) -> 50*i)
		.attr("opacity", 1)
		.attr('font-size', window.vis_config.smaller_font_size)

	# paint the areas
	sector_area_chart = 
		area_chart.selectAll('.sector_area')
			.data(yearSectorStack)
			.enter().append('path')
			.attr('class', 'sector_area overlay')
			.attr("id", (d,i) -> "sectorPath"+i)
			.attr("fill", (d,i) ->  
				window.vis_config.c_sector(sectorSums[i].key) )
			.attr("d", null_area)
			.transition()
				.duration(600)
				.attr("d", sector_area)
	#console.log "after sector graph years: ", window.vis_config.years
	make_top_projects(overlay, active_country, sectorSums, sector_area_x, sector_area_y, area_chart)


make_top_projects = (overlay, active_country, sectorSums, sector_area_x, sector_area_y, area_chart) ->
	w = window.vis_config.w
	h = window.vis_config.h
	top_projects_offset_x = 20
	top_projects_offset_y = (58/80)*h
	top_projects_height = (2/8)*h
	top_projects_width  = .5*w	
	top_projects_group = overlay.append('svg:g')
		.attr('id', 'top_projects')
		.attr('transform', 'translate('+top_projects_offset_x+', '+top_projects_offset_y+')')
		.append('svg:foreignObject')
			.attr("id", "top_projects_body")
			.attr("height", .05*h)
			.attr("width", top_projects_width)
			.style("background-color", "hsla(319, 0%, 100%, 0.7)")
			.style("margin","0 0 0 0")
			.style("padding","5px 5px 5px 5px")
			.append("xhtml:body")
				.attr('height', .05*h)
				.style('background-color', 'transparent')
				.style('color', 'black')
				.html("<p><b>Loading top projects...</b></p>")

	top_projects_path = '/projects.json?max=5' + 
		(if current_scope.name != "All Projects" then "&scope_names[]=" + current_scope.name else "") +
		"&active_string=Active" +
		"&order_by=usd_2009&dir=desc" +
		"&recipient_iso2=" + active_country.iso2

	# top_projects_params = @active_params || {}
	# top_projects_params.active_string =  "Active"
	# top_projects_params.order_by = "usd_2009"
	# top_projects_params.dir = "desc"
	# top_projects_params.max = top_projects_number = 5
	top_projects_number = 5
	# top_projects_params.recipient_iso2 = active_country.iso2
	# delete top_projects_params?.get
	c_projects = d3.scale.linear()
		.domain([0, ((top_projects_number-1)/2), top_projects_number-1])
		.range(['#2A5C0B', '#55760f','#808f12'])

	# $.get(top_projects_path, top_projects_params, (top_projects_data) -> 
	$.get(top_projects_path, (top_projects_data) -> 
		#console.log(top_projects_data)
		plot_top_projects(top_projects_data, sectorSums, c_projects, sector_area_x, sector_area_y, area_chart)
		create_top_projects_box(active_country, top_projects_data, "top_projects_body", top_projects_height, c_projects)
	, "json")		

create_top_projects_box = (active_country, projects, target, height, c_projects) ->
	#console.log "before top projs box years: ", window.vis_config.years

	body_html = "<div style='text-align:left;font-size:#{window.vis_config.medium_font_size};'>" + 
		"<p><b>Top projects in #{active_country.name}:</b></p><ul>"
	projects.forEach((p, i) ->
		body_html += "<li style='color:#{c_projects(i)}'>" + 
		"<span style='color:black'><a href='/projects/#{p.id}'>#{p.title}</a> (#{(p.year ? "<i>no year</i>")})," + 
		" $#{window.vis_config.nicemoney(p.usd_2009)}</span></li>"
	)
	body_html +="</ul>
		<p><a href='/projects?country_name=#{active_country.name}&active_string=Active'>
			See all projects in #{active_country.name} &rarr;
			</a>
			</p>
		</div>"

	foreign_object = d3.select('#'+target);

	foreign_object
		.transition()
		.attr('height', 0)

	foreign_object_jq = $('#'+target)
	foreign_object_jq.children().remove()
	foreign_object_jq.append('<xhtml:body>'+body_html+'</xhtml:body>')

	foreign_object
		.transition()
		.attr('height', height)

plot_top_projects = (projects, sectorSums, c_projects, sector_area_x, sector_area_y, area_chart) ->
	sectors = sectorSums.map((s) -> s.key )

	point_stack_height = (project) -> 
	# UH oh, what if there are 2 in the same year?
		stack_object = yearSectorStack[sectors.indexOf(project.crs_sector_name)][project.year-d3.min(@years)]
		if stack_object
			stack_object.y0 + stack_object.y 
		else
			0
	project_points = area_chart.selectAll('.project_point')
		.data(projects)
		.enter().append('svg:circle')
	project_points.attr('cx', (d) ->  sector_area_x(d.year))
			.attr('cy', (d) ->  sector_area_y(d.usd_2009))
			.attr('r', '0px')
			.attr('fill', (d,i) -> c_projects(i))
			.attr('stroke','black') #(d) ->  c_sector(d.crs_sector_name))
			.attr('stroke-weight', 1)
			.transition()
				.duration(500)
				.delay((d,i) -> i * 200)
				.attr('r', '3px')

	project_points.append('title')
				.text((d) ->  d.title)


make_gni_chart = (overlay, active_country) ->
	#console.log "before gni_chart years: ", window.vis_config.years
	w = window.vis_config.w
	h = window.vis_config.h
	line_chart = {}
	line_chart.height = (1/8)*w
	line_chart.width = .35*w
	line_chart.offset_y = (60/80)*h
	line_chart.offset_x = w - line_chart.width - 50
	line_chart.text_margin = 33

	line_chart.selection = overlay.append('svg:g')
		.attr('id', 'line_chart')
		.attr('transform', "translate(#{line_chart.offset_x}, #{line_chart.offset_y})") 
	
	line_chart.selection.append('svg:rect')
			.attr('id', 'line_chart_background')
			.attr('x', -.025*w)
			.attr('y', -.025*h)
			.attr('height', (.2*w))
			.attr('width', line_chart.width + 50)
			.attr('stroke', 'transparent')
			.style('fill', 'hsla(0, 0%, 10%, 0.5)')

	# request related data, then call a function to draw the line chart
	wbi_call = (country_iso, indicator_code) ->
		encodeURIComponent(
			"http://api.worldbank.org/countries/#{country_iso}/indicators/#{indicator_code}?per_page=50&date=1999:2012&format=json"
		)
	window.worldbank_gni_url = wbi_call active_country.iso2, "NY.GNP.ATLS.CD"
	window.worldbank_dacoda_url = wbi_call active_country.iso2, "DC.DAC.TOTL.CD"
	window.worldbank_usaoda_url = wbi_call active_country.iso2, "DC.DAC.USAL.CD"
	cdf_path = "/aggregates/projects?get=year" + 
		$("#scope_Official_Finance").attr("data-aggregate-params") +
		"&recipient_iso2=#{active_country.iso2}"
	
	# Right now, these ajax called are made in sequence -- can they be made in parallel?
	#console.log( "starting wdi calls")
	d3.json("/ajax?url=#{worldbank_gni_url}", (gni_data) ->
		d3.json("/ajax?url=#{worldbank_dacoda_url}", (dacoda_data) ->
			d3.json("/ajax?url=#{worldbank_usaoda_url}", (usaoda_data) ->
				d3.json(cdf_path, (cdf_data) ->
					create_line_graph(line_chart, gni_data, [{name: "Chinese O.F.", data: cdf_data, source: cdf_path, color: "#cc3333"}, 
					{name: "DAC ODA", data: dacoda_data, source: worldbank_dacoda_url, color: "#6699ff"}, 
					{name:"USA ODA", data: usaoda_data, source: worldbank_usaoda_url, color: "cccc66"}
					], worldbank_gni_url)
				)
			)
		)
	)

create_line_graph = (line_chart, gni_data, oda_array, worldbank_gni_url) ->
	#console.log(oda_array)
	# oda_array objects are {name: "Name", data: (unprocessed data...), source: "Some URL", color: "display CSS color"}
	# constants were set before function call!
	line_chart.selection.transition()
		.attr('height', line_chart.height + line_chart.text_margin + 25)

	years = window.vis_config.years
	
	oda_array.forEach((d) ->
		d.graph_data = []  
		#console.log years, window.vis_config.years
		if d.source.indexOf('api.worldbank')!=-1 	# That is, it's from World Bank, so give it the treatment
			#console.log('checking WDI array', d)
			for y in years
				# find the right point then push it. 
				#console.log y
				amount = d.data[1].filter((c) -> Number(c.date) is y)[0]
				gni_value = gni_data[1].filter((c) -> Number(c.date) is y)[0]?.value
				if gni_value && amount
					data_point = [y, (100*Number(amount.value))/Number(gni_value)]
					#console.log data_point
					d.graph_data.push(data_point)	
		else if (d.source.indexOf('aggregates/projects')!=-1)  # That is, it's from the China API
			#console.log("checking internal array", d)
			for y in years
				amount = d.data.filter((c) -> Number(c.year) is y)[0]  
				gni_value = gni_data[1].filter((c) -> Number(c.date) is y)[0]?.value
				#console.log amount, gni_value
				if amount && gni_value
					data_point= [y, (100*Number(amount.usd_current))/Number(gni_value)]
					d.graph_data.push(data_point)	
	)
	annual_maximum_finance_over_gni = d3.max(oda_array.map((a) -> d3.max(a.graph_data,(v) -> v[1])))
	line_percent_scale = d3.scale.linear().domain([0,(annual_maximum_finance_over_gni + (annual_maximum_finance_over_gni/10))]).range([line_chart.height, 0])
	line_year_scale = d3.scale.linear().domain([d3.min(years), d3.max(years)]).range([0,line_chart.width])

	if years.length >= 6 # for style
		line_xAxis = d3.svg.axis()
			.scale(line_year_scale)
			.orient('bottom')
			.ticks(6)
			.tickFormat(d3.format("f")) 
	else 
		line_xAxis = d3.svg.axis()
			.scale(line_year_scale)
			.orient('bottom')
			.tickValues(years)
			.tickFormat(d3.format("f"))   

	line_chart.selection.append("svg:g")
		.attr('class', 'axis')
		.call(line_xAxis)
		.style('fill', '#ccc')
		.attr('transform', 'translate(0,'+(line_chart.height+2)+')')
		.attr("opacity", 1)
	# paint the percent labels
	line_yAxis = d3.svg.axis()
		.scale(line_percent_scale)
		.ticks(4)
		.orient('right')

	line_chart.selection.append("svg:g")
		.attr('class', 'axis')
		.call(line_yAxis)
		.style('fill', '#ccc')
		.attr('transform', 'translate('+line_chart.width+')')
		.attr("opacity", 1)

	#console.log line_year_scale, line_percent_scale, years
	#console.log oda_array, gni_data
	gni_line = d3.svg.line()
		.x((d) -> line_year_scale(d[0]))
		.y((d) -> line_percent_scale(d[1]))
	gni_stroke_width = 3  

	line_chart.selection.selectAll('.gni_line')
		.data(oda_array)
		.enter().append('svg:path')
			.attr('class', 'gni_line')
			.attr('d', (d) ->  gni_line(d.graph_data))
			.style('stroke', (d) ->  d.color)
			.style('fill', 'transparent')
			.style('opacity', '.6')
			.attr('stroke-width', gni_stroke_width)

	# paint line labels
	line_chart.selection.selectAll('.gni_label')
		.data(oda_array)
		.enter().append('svg:text')
			.attr('class', 'gni_label')
			.text((d) ->  d.name)
			.style('fill', (d) ->  d.color)
			.attr('text-anchor', 'bottom')
			.attr('x', (d,i) -> ((3+(i*10))/80) * window.vis_config.w )        
			.attr('y', line_chart.height + line_chart.text_margin)

	# paint the heading
	line_chart.selection.append('svg:text')
		.text("Finance/GNI (%)")
		.style('fill', 'white')
		.attr('text-anchor', 'top')
		.attr('y', 0)
		.attr('x', (line_chart.width/2)-(this.length/2))
		.style('font-weight', 'bold')

	# paint sources
	line_chart.selection.append('svg:foreignObject')
		.attr('x', -.025*window.vis_config.w)
		.attr('y', line_chart.height + line_chart.text_margin + 5)
		.attr('width', line_chart.width + 50)
		.attr('height', .025*window.vis_config.h)
		.append('xhtml:body')
			.style('padding', '2px 2px 2px 2px')
			.style("background-color", "hsla(319, 0%, 100%, 0.5)")
			.style('text-align', 'center')
			.style('vertical-align', 'center')
			.html("<p style='color:#333;font-size:#{window.vis_config.medium_font_size};'>"+
				"<b>Sources: </b> <a href='#{worldbank_gni_url}'>GNI</a>, " +
				"#{oda_array.map((d) ->  "<a href='#{d.source}'>#{d.name}</a>").join(', ')}</p>")

	#console.log "finished line chart", oda_array, gni_data

window.click = () ->
	# Inactive countries don't get click listeners.
	
	active_country = get_active_country(this) # returns .iso2 and .name
	overlay = drop_overlay()
	sector_data_path = '/aggregates/projects?get=crs_sector_name,year' + 
		current_scope.aggregate_params +
		"&recipient_iso2=" +active_country.iso2 +
		"&multiple_recipients=percent_then_share"
	# window.active_params.get = 'crs_sector_name,year'
	# window.active_params.recipient_iso2 = active_country.iso2
	# window.active_params.multiple_recipients = 'percent_then_share'
	
	# $.get("aggregates/projects", window.active_params, (json) ->
	$.get(sector_data_path, (json) ->
		active_country.data = json
		#console.log(active_country)
		make_sector_graph(overlay, active_country)
		make_pie_chart(overlay, active_country)
		# make_gni_chart(overlay, active_country)
	, "json")
	make_header(overlay, active_country)