@App = @App || {}

App.config =
	chart_title: "China in Africa"
	chart_longer_title: "China in Africa"

	vis_height: 400
	vis_width: 800
	vis_padding_left: 100
	vis_padding_top: 10
	vis_padding_bottom: 150

	# Set this to true to rescale
	# every time the vis renders.
	always_rescale_to_fit: false
	always_remove_blanks: false

	# joins params in the url
	param_joiner: '-and-'

	now_showing:
		# the now_showing object has a k:v for each of the filter columns
		# and ["measure"] for the active measure.
		# It should return a string to display in the to right.
		(ns) -> "#{ns.Year} #{ns.measure} 
		#{ns.Recipient} #{ns.Flow_Class} for #{ns.Purpose}"
	
	data:

		file: 
			# This is the relative path to the target data file.
			# "aiddata2_1_donor_recipient_year_purpose.csv"
			# "china_active.csv"
			'/javascripts/aiddata_china_1_0_official.csv'

		get_file_size:
			# if true, shows loading bar
			# NOT IMPLEMENTED
			false

		preprocessing_function: 
			# This function is called on the loaded data file.
			# (data) -> data
			(data) -> (d for d in data when parseInt(d.year) >=1980)

		record_hyperlink_function:
			# this returns the hyperlink for a given record.
			(d) -> "http://china.aiddata.org/projects/#{d.ProjectID}"
			
		columns: [
			# This is an array of objects with three attributes:
			#	name: 				becomes the name in the application
			#	values_function: 	function for populating this data field --> takes one argument, the csv data set.
			#	interface_type:		how is it used in the interface? one of: ["filter", "value", "none"]
			#	dv_type:			datavore column type, one of: [dv.type.ordinal, dv.type.nominal, dv.type.numeric]
			#	
			{
				name: "Commitment",
				values_function: (data) -> (Number(d.usd_defl) for d in data) # commitment_amount_usd_constant					 
				interface_type: "value",
				dv_type: dv.type.numeric
				now_showing:
					value: (d) ->"China gave $#{d3.format(',.2f')(d)}"
			},
			{
				name: "Count",
				values_function: (data) -> (1 for d in data)  #
				interface_type: "value",
				dv_type: dv.type.numeric
				now_showing:
					value: (d) -> "China had #{d} projects"
			},
			# {
			# 	name: "Average"
			# 	values_function: (data) -> data.map((d) -> 
			# 		parseFloat( d.commitment_usd_constant_sum  || 0)/(parseInt(d.record_count)))
			# 	interface_type: "value"
			# 	dv_type: dv.type.numeric
			# },
			{
				name: "Year",
				values_function: (data) -> data.map((d) -> d.year),
				interface_type: "filter",
				dv_type: dv.type.ordinal
				now_showing:
					single: (single) -> "In #{single},"
					multiple: (multiple) -> "Over #{multiple.length} years, "
			},
			{
				name: "Recipient",
				values_function: (data) -> ( d.recipient_condensed for d in data), #_condensed),
				interface_type: "filter",
				dv_type: dv.type.nominal
				now_showing:
					single: (single) -> "to #{single}"
					multiple: (multiple) -> "" #"to #{multiple.length} countries "
			},
			# {
			# 	name: "Donor",
			# 	values_function: (data) -> data.map((d) -> d.donor),
			# 	interface_type: "filter",
			# 	dv_type: dv.type.ordinal
			# },
			{ 
				name: "Flow_Class"
				values_function: (data) -> (d["flow_class"] for d in data)
				interface_type: "filter"
				dv_type: dv.type.ordinal
				now_showing:
					single: (single) -> "as #{single}"
					multiple: (multiple) -> "" #by #{multiple.length} modalities"
			},
			{
				name: "Purpose",
				values_function: (data) -> (d.crs_sector_name for d in data)
				interface_type: "filter",
				dv_type: dv.type.ordinal
				now_showing:
					single: (single) -> "for #{single}"
					multiple: (multiple) -> "for #{multiple.length} sectors"
			},
			{ 
				name: "Intent"
				values_function: (data) -> (d["intent"] for d in data)
				interface_type: "filter"
				dv_type: dv.type.ordinal
				now_showing:
					single: (single) -> "for #{single}"
					multiple: (multiple) -> "" #by #{multiple.length} modalities"
			},
			{ 
				name: "Status"
				values_function: (data) -> (d["status"] for d in data)
				interface_type: "filter"
				dv_type: dv.type.ordinal
				now_showing:
					single: (single) -> "for #{single}"
					multiple: (multiple) -> "" #by #{multiple.length} modalities"
			},
			{ 
				name: "Flow"
				values_function: (data) -> (d["flow"] for d in data)
				interface_type: "filter"
				dv_type: dv.type.ordinal
				now_showing:
					single: (single) -> "for #{single}"
					multiple: (multiple) -> "" #by #{multiple.length} modalities"
			},
			{
				name: "ProjectID",
				values_function: (data) -> (d.project_id for d in data)
				interface_type: "none"
				dv_type: dv.type.ordinal
			}
		]

$('title').text App.config.chart_title
$('#chart_title').text App.config.chart_title
$('#chart_longer_title').text App.config.chart_longer_title