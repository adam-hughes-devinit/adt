
lay_down_base_layers = () ->
	@active_params = {}

	# This does everything until data gets involved
	# 1) SVG base layers
	# 2) @map_data (scaffold for color data)

	add_other_features_to_collection_and_make_map_data = () ->
		
		# For no good reason, the features are split in 2 files
		# Oh I just remembered -- I had one file for Africa, one for others

		@other_features.forEach((feature) -> 
		  #console.log('f', feature)
		  feature.properties.id = "non_african"
		  @collection.features.unshift(feature)
		)
		window.map_data = d3.nest()
			.key((d) -> d.properties.id)
			.rollup((d) -> "value" : null, "value_current": null)
			.entries(collection.features)
		window.map_data_item = (iso2) ->
			item = window.map_data.filter((m) -> m.key == iso2)[0]
			item ? null

	create_svg = () ->
		# Set the Height and Width here to influence the rest of the application
		h = 800
		w = h

		# I'm creating a global variable
		# called vis_config which holds a bunch of important values and functions.

		m = window.vis_config
		window.vis_config = 
			label_green: d3.rgb("#819014") # This is green for the overlay label
			c_sector: (sector_name) ->
				sector_color_map = {}
				( sector_color_map[c.name] = c.color for c in  CRS_SECTOR_COLORS)
				sector_color_map[sector_name]
			nicemoney: (amount) ->
				if 100 > amount 
					"#{d3.format("0,r")(d3.round(amount,0))}"
				else if 1000000 > amount >= 1000
					"#{d3.round((amount/1000),0)}K"
				else if 1000000000 > amount >= 1000000
					"#{d3.round((amount/1000000),1)}M"
				else if amount >= 1000000000
					"#{d3.format("0,r")(d3.round((amount/1000000000),2))}B"
			nicemoneyaxis: (amount) ->
				if 100 > amount 
					"#{amount.toFixed(0)}"
				else if 1000000 > amount >= 1000
					"#{(amount/1000).toFixed(0)}K"
				else if 1000000000 > amount >= 1000000
					"#{ (amount/1000000).toFixed(0) }M"
				else if 1000000000 <= amount
					"#{(amount/1000000000).toFixed(0)}B"
			w: w
			h: h
			xy: d3.geo.mercator().scale(w*4.5).translate([.125*w,.375*h])
			c: d3.scale.linear().domain([0,8000000000,150000000000]).range(['#FAEDD9', '#808F12', '#2A5C0B'])
			logscale: d3.scale.log().domain([1, 150000000000])
			grayscalec: d3.scale.linear().domain([2,3]).range(['#000000','#FFFFFF'])
			money: d3.format("0,r")
			years: d3.range(2000,2012)
			total_cdf_in_view: 0
			active_params: {}
			bigger_font_size: d3.max([(14/800)*w,13])
			medium_font_size: d3.max([(12/800)*w,12])
			smaller_font_size: d3.max([(10/800)*w,10])
		window.vis_config.path = d3.geo.path().projection(window.vis_config.xy)
		
		@vis = d3.select("#vis")
				.append("svg:svg")
					.attr("id", "africa-map")
					.attr("width", w)
					.attr("height", h)

		@vis.append("svg:defs")
			  .append("svg:filter")
			    .attr("id", "blur")
			  .append("svg:feGaussianBlur")
			    .attr("stdDeviation", 5);

		"finished"

	create_ocean_and_states = () ->
		map = vis.append("svg:g")
			.attr("id", "states")
			.attr("transform","translate(100,"+ window.vis_config.w/7 + ")")
		# Nice blue outline was made by hand in Inkscape
		ocean = map.append("svg:path")
			.attr("id", "ocean_outline")
			.attr("d", @ocean_outline_d)
			.attr("stroke-width", 10)
			.attr("stroke", "darkblue")
			.style('fill', 'transparent')
			.attr('transform', 'scale('+(window.vis_config.h/800)+') translate(-130, -'+((1.255/8)*window.vis_config.h)+')')
			.attr('filter', "url(#blur)")
		countries =  d3.select("#states")
    		.selectAll(".country")
			.data(@collection.features)
			.enter().append("svg:path")
				.attr("class", (d) ->  
					if d.properties.id == "non_african" 
						"non_african" 
					else "fuzz country")
				.attr("id", (d, i) ->  
					if d.properties.id == "non_african" 
						""
					else
						d.properties.id)
				.attr("name", (d) ->  d.properties.name)
				.attr("d", window.vis_config.path)
				.attr("stroke-width", 1)
				.attr("stroke", "#333")
				.attr("fill", "#777")
				.attr("filter", "url(#blur)")

		$('path#CV').attr("transform","translate (80,100)")


	create_frame = () ->
		# For style
		h = window.vis_config.h
		w = window.vis_config.w
		border_line_array = [
			[0,0,0,h], [0,h,w,h], [w,h,w,0], [w,0,0,0]
		]
		frame = vis.append('svg:g')
			.attr('id', 'border_lines')
			.selectAll('.border_line')
			.data(border_line_array)
			.enter().append('svg:line')
				.attr('class', 'border_line')
				.attr('x1',(d) -> d[0])
				.attr('y1',(d) -> d[1])
				.attr('x2',(d) -> d[2])
				.attr('y2',(d) -> d[3])
				.attr('stroke', '#eee')
				.attr('stroke-width', 8)

	add_other_features_to_collection_and_make_map_data()
	create_svg()
	create_ocean_and_states()
	create_frame()
	"finished"


lay_down_base_layers()

