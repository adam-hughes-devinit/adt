@C = new Marionette.Application()

@clean_value = (value) ->
	value.replace(/[\-\+:'\(\)\/\\\s&,\.#]+/g, "_")	

$(() ->
	C.start()
	console.log("started")
)

padding = 10
C.vis = 
	padding: padding
	h: 2000 + (padding * 3)
	w: $('#grid_vis').parent().parent().width() + (padding * 3)
	el: "#grid_vis"
	base_opacity: "0.5"
	label_length: 100
	label_padding: 2
	label_font_size: 12
	highlight: "#d1002f"
C.vis.label_height = (C.vis.label_font_size * 3) + (C.vis.label_padding * 2 )

C.addRegions(
	vis_region: "#grid_vis"
	tooltip_region: "#grid_tooltip"
	controls_region: "#controls"
	projects_region: "#project-body"
)

C.tooltip_region.on("show", () ->
	# gotta set window.m
	# console.log this
	this.$el.show()
)

C.tooltip_region.on("close", () ->
	this.$el.hide()
)

C.projects_region.on("show", () ->
	this.$el.parent().modal('show')
	
)
C.projects_region.on("close", () ->
	this.$el.parent().modal('hide')
)

C.addInitializer(() ->
	console.log("initializing")
	C.router = new C.Router
	C.tooltip_region.close()
	C.controls = new C.Controls({model: {
		x_options: [
			{value: "sector_name", name: "Sector"}
			{value: "flow_class_name", name: "Flow Class"}
			{value: "year", name: "Year"}
			{value: "intent_name", name: "Intent"}
		]
		y_options: [
			{value: "sector_name", name: "Sector"}
			{value: "flow_class_name", name: "Flow Class"}
			{value: "year", name: "Year"}
			{value: "recipient_name", name: "Recipient"}
			{value: "intent_name", name: "Intent"}
			{value: "status_name", name: "Status"}
		]
		}})
	C.controls_region.show(C.controls)
	$(document).mousemove((e) ->
		$('#grid_tooltip').css("left", e.pageX + 10).css("top",e.pageY + 10)
	)
	$('#project_modal').on('hide', () ->
		console.log "hiding!"
		C.projects_region.close()
		x_axis = $("#x_axis").val()
		y_axis = $("#y_axis").val()
		C.router.navigate("graph/" + x_axis + "/" + y_axis, {trigger: false})
	)
	
)

C.on('initialize:after', () ->
	C.svg = d3.select(C.vis.el)
		.append("svg")
		.attr("height", C.vis.h)
		.attr("width", C.vis.w)

	C.boxes_g = C.svg.append("svg:g")
		.attr("id", "boxes_g")
		.attr("transform", "translate("+(C.vis.padding+C.vis.label_length)+","+(C.vis.padding+C.vis.label_length)+")")

	C.x_labels = C.svg.append("svg:g")
		.attr("id", "x_labels")
		.attr("class", "axis")
		.attr("transform", "translate(" + (C.vis.label_length) + ", " + (0 * (C.vis.label_length)) + ")")

	C.y_labels = C.svg.append("svg:g")
		.attr("id", "y_labels")
		.attr("class", "axis")
		.attr("transform", "translate(" + C.vis.label_length + ", " + (C.vis.label_length ) + ")")



	d3.csv('/javascripts/aiddata_china_1_0_official.csv', (data) ->
		C.data = dv.table([
			{name: "project_id", type: dv.type.numeric, values: _.pluck(data, "project_id")}
			{name: "title", type: dv.type.unknown, values: _.pluck(data, "title")}
			{name: "usd_2009", type: dv.type.numeric, values: _.map(data, (d) -> Number(d["usd_defl"]) )}
			{name: "recipient_name", type: dv.type.nominal, values: _.pluck(data, "recipient_condensed")}
			{name: "sector_name", type: dv.type.nominal, values: _.pluck(data, "crs_sector_name")}
			{name: "intent_name", type: dv.type.nominal, values: _.pluck(data, "intent")}
			{name: "status_name", type: dv.type.nominal, values: _.pluck(data, "status")}
			{name: "flow_class_name", type: dv.type.nominal, values: _.pluck(data, "flow_class")}
			{name: "year", type: dv.type.nominal, values: _.pluck(data, "year")}
			])	
		# console.log C.data	

		Backbone.history.start()	
	)	
)

C.Router = Backbone.Marionette.AppRouter.extend({
	appRoutes: {}
	routes:
		"" : "root"
		"graph/:x/:y/:x_val/:y_val" : "show_projects_by_x_y"
		"graph/:x/:y" : "graph_by_x_y"


	root: () ->
		this.graph_by_x_y("sector_name", "recipient_name")

	show_projects_by_x_y: (x, y, x_val, y_val) ->
		C.correlate(x,y, {also_show_projects: [x_val, y_val]})

	graph_by_x_y: (x, y=null) ->
		C.correlate(x,y)
})

C.show_projects = (d, i) ->
	console.log "showing projects for ", d
	x_value = d[0]
	x_axis = $("#x_axis").val()
	y_value = d[1]
	y_axis = $("#y_axis").val()

	C.router.navigate("graph/" + x_axis + "/" + y_axis +  "/" + x_value + "/" + y_value, {trigger: false})

	projects = C.data.where((table, row) ->
		table.get(x_axis, row) is x_value and table.get(y_axis, row) is y_value
	)
	# console.log "result", projects
	projects = projects.toJSON()
	projects = _.sortBy(projects, (d) -> -1 * d["usd_2009"])
	# console.log "json", projects
	projects = new C.ProjectCollection(projects)
	# console.log "collection", projects
	
	project_modal = new C.ProjectTable({
		collection: projects
	})
	
	C.projects_region.show(project_modal)

C.correlate = (x,y,options={}) ->

	# console.log(x,y)
	$("#x_axis").val(x)
	$("#y_axis").val(y)
	
	C.router.navigate("graph/" + x + "/" + y, {trigger: true})

	dims = [x ,y]
	graph_data = C.data.query(
		dims: dims
		vals: [dv.sum("usd_2009"), dv.count()]
	)


	# console.log "graph_data", graph_data

	x_vals = _.uniq(graph_data[0])
	if y?
		y_pos = 1
		y_vals = _.uniq(graph_data[1])
		amounts = graph_data[2]
	else
		amounts = graph_data[1]

	# resize some stuff 
	C.vis.h = (y_vals.length) * C.vis.label_height
	C.vis.w =  (x_vals.length) * C.vis.label_height

	max_amount = d3.max amounts
	total_amount = d3.sum amounts

	# console.log "max", max_amount, "total", total_amount
	box_size = Math.round( 
		Math.max(
			C.vis.label_height,
			Math.min( 
				(C.vis.w - (C.vis.padding * 3) - C.vis.label_length) / x_vals.length,  
				(C.vis.h - (C.vis.padding * 3 ) - C.vis.label_length)/y_vals.length
			)
		)
	)
	box_width = box_size # Math.round( (C.vis.w) / x_vals.length)
	box_height = box_size # Math.round( (C.vis.h) /  y_vals.length )	


	x_scale = d3.scale.ordinal()
		.domain(x_vals)
		.rangeBands([0, box_width * x_vals.length], .1)

	x_labels = C.x_labels.selectAll('.label-holder')
		.data(x_scale.domain(), (d) -> d)
	x_labels.exit().remove()
	x_label_holders = x_labels.enter()
		.append("g")
			.attr("class", (d) -> clean_value(d) + "-label x label-holder")
		
	x_label_holders
		.append("foreignObject")
			# location handled by containing G
			.attr("x", 0)
			.attr("y", 0)
			.attr("width", C.vis.label_length)
			.attr("height", C.vis.label_height)
			.append("xhtml:body")
				.append("p")
					.text(String)
					.style("font-size", C.vis.label_font_size + "px")
					.style("line-height", C.vis.label_font_size + "px")

	d3.selectAll(".x.label-holder")			
	 	.attr("transform", (d) -> "rotate(-90)translate(" + -(C.vis.label_length) + "," +
	 		x_scale(d) + ")")

	y_scale = d3.scale.ordinal()
		.domain(y_vals)
		.rangeBands([0, box_height * y_vals.length], .1)


	y_labels = C.y_labels.selectAll('.label-holder')
		.data(y_scale.domain(), String)
	
	y_labels.exit().remove()
	
	y_label_holders = y_labels.enter()
		.append("g")
			.attr("class", (d) -> clean_value(d) + "-label y label-holder")
		
	y_label_holders
		.append("foreignObject")
			.attr("x", -C.vis.label_length)
			.attr("y", (d) -> y_scale(d))
			.attr("width", C.vis.label_length)
			.attr("height", C.vis.label_height)
			.append("xhtml:body")
				.append("p")
					.text(String)
					.style("font-size", C.vis.label_font_size + "px")
					.style("line-height", C.vis.label_font_size + "px")
	
	amount_scale = d3.scale.linear()
		.domain([0,.0001, max_amount/2, max_amount])
		.range(['white', 'blue','purple','red'])
	
	max_radius = box_size
	
	radius_scale = d3.scale.linear()
		.domain([0,.0001, max_amount/2, max_amount])
		.range([0, max_radius * .2, max_radius * .5, max_radius])

	data = _.zip.apply(null, graph_data) # each to array

	# console.log data 
	
	highlight = (d,i) ->
		x_value = $(this).attr("data-x-value")
		y_value = $(this).attr("data-y-value")
		color = amount_scale(d[2])
		
		guidelines = C.boxes_g
			.insert("g", ":first-child")
				.attr("class", "guidelines")
		guidelines.append("line")
			.attr("x1", x_scale(d[0]))
			.attr("y1", 0)
			.attr("x2", x_scale(d[0]))
			.attr("y2", C.vis.h)
			.style("stroke", color)
			.style("opacity", ".4")
		guidelines.append("line")
			.attr("x1", 0)
			.attr("y1", y_scale(d[1]))
			.attr("x2", C.vis.w)
			.attr("y2", y_scale(d[1]))
			.style("stroke", color)
			.style("opacity", ".4")

		$("."+x_value+", ."+y_value).css("opacity", ".8")
		labels = $("."+x_value+"-label, ."+y_value+"-label").find("p")
		labels.css("color", C.vis.highlight)

		$(this).css("opacity", "1")
		
		if d[3] > 0
			current_tooltip = new C.Tooltip({model: {
				x_value: d[0]
				y_value: d[1]
				amount: d[2]
				count: d[3]
			}})


			C.tooltip_region.show( current_tooltip )

	unhighlight = () ->
		$('.box').css("opacity", C.vis.base_opacity)
		$('.label-holder').find("p").css("color", "inherit")
		C.tooltip_region.close()
		C.boxes_g.select(".guidelines").remove()





	boxes = C.boxes_g.selectAll(".box")
			.data(data, (d) -> clean_value(d[0])+" "+clean_value(d[1]) + " box" )
	
	boxes.exit()
		.transition()
			.style("opacity","0")
			.remove()
	boxes
		.enter().append("svg:circle")

			# .attr("height", box_height)
			# .attr("width", box_width)
			.attr("cy", (d) -> y_scale(d[1]))
			.attr("cx", (d) -> x_scale(d[0]))
			.attr("r", 0)
			.attr("class", (d) -> clean_value(d[0])+" "+clean_value(d[1]) + " box" )
			.attr("data-x-value", (d) -> clean_value(d[0]))
			.attr("data-y-value", (d) -> clean_value(d[1]))
			.style("opacity", C.vis.base_opacity)
			.style("fill", "white")
			.style("cursor", "pointer")
			.on("mouseover", highlight)
			.on("mouseout", unhighlight)
			.on("click", C.show_projects)
	

	boxes
		.transition()
			.delay((d,i) -> Math.random() * 500 )
			.duration(200)
			.attr("r", (d) -> radius_scale(d[2]))
			.style("fill", (d) -> amount_scale(d[2]))
	
	if options?.also_show_projects

		x_val = options.also_show_projects[0]
		y_val = options.also_show_projects[1]
		desired_datum = [
			x_val, y_val
		]
		console.log "Desired datum", desired_datum
		C.show_projects(desired_datum) 

C.Tooltip = Backbone.Marionette.ItemView.extend(
	template: "#tooltip_template"
	serializeData: () -> this.model
)	

C.Controls = Backbone.Marionette.ItemView.extend(
	template: "#controls_template"
	serializeData: () -> this.model
	events: 
		"change select" : "make_new_graph"

	make_new_graph: () ->
		x = $('#x_axis :selected').val()
		y = $('#y_axis :selected').val()
		C.correlate(x, y)

)

C.Project = Backbone.Model.extend()

C.ProjectCollection = Backbone.Collection.extend(
	model: C.Project
)
C.ProjectRow = Backbone.Marionette.ItemView.extend(
	template: "#project_tr"
	model: C.Project
	tagName: "tr"
)

C.ProjectTable = Backbone.Marionette.CompositeView.extend(
	template: "#project_table"
	itemView: C.ProjectRow
	itemViewContainer: "tbody"
	onAfterRender: () -> ApplySortability()
)