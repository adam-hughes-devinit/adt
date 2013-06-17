@log = (args...) -> (console.log a for a in args)

@App = @App || {}

App.map = L.map('map').setView([0, 23], 3)
App.layers = {}

L.tileLayer(
	'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
	    attribution: 'Map data &copy; OpenStreetMap contributors',
	    maxZoom: 18
	})
	.addTo(App.map);

App.collection = new Miso.Dataset({
	url: '/javascripts/collection_latlong.json'
	extract: (data) -> 
		data.features
})

App.zoom_to = (iso2) ->
	this_layer = App.layers[iso2]
	App.map.fitBounds(this_layer.getBounds())
	this_name = this_layer.feature.properties.name
	if this_name is "Central African Republic"
		this_name = "Central African Rep."
	App.display_country(this_name)

App.collection.fetch({
	error: () -> alert("couldn't fetch countries")
	success: () ->
		countries = L.geoJson(this.toJSON(),{
				style: 
					"weight": 1,
					"color" : "#aaaaaa"
					"fillOpacity" : 0.45
					"clickable" : true
				onEachFeature: (feature, layer) ->
					App.layers[feature.properties.id] = layer
					layer.on {
						mouseover: (e) ->
							layer = e.target
							layer.setStyle({
								weight: 2
								fillOpacity: 0.7
								})
							if !L.Browser.ie and !L.Browser.opera 
								layer.bringToFront
						mouseout: (e) ->
							layer = e.target
							layer.setStyle({
								weight: 1
								fillOpacity: .45
								})
						click: (e) ->
							country_iso2 = e.target.feature.properties.id
							Finch.navigate "/#{country_iso2}"
					}
			})

		countries.addTo(App.map)
		App.fetch_country_data()
	})


App.data = 
	full: new Miso.Dataset({
		url: "/aggregates/projects?get=recipient_iso2,recipient_name,crs_sector_name,year"
		columns: [
			{name: "recipient_iso2", type: "string"}
			{name: "recipient_name", type: "string"}
			{name: "year", type: "number" }
			{name: "crs_sector_name", type: "string"}
			{name: "usd_2009", type: "number", before: (v) -> (if !v? then 0 else v) }
			{name: "count", type: "number", before: (v) -> (if !v? then 0 else v)}
		]
		})

App.fetch_country_data = ->
	App.data.full.fetch({
		error: () -> alert("couldn't load finance data.")
		success: () ->
			# log this.toJSON()
			# with more params, have to groupBy

			App.data.by_country = App.data.full.groupBy("recipient_iso2", ["usd_2009"])
			
			by_country = App.data.by_country

			max_amount =  (by_country.max("usd_2009"))
			country_color = d3.scale.linear()
				.domain([0, max_amount/3, max_amount ])
				.range(['#FAEDD9', '#808F12', '#2A5C0B'])

			by_country.each (row) ->
				if this_country = App.layers[row["recipient_iso2"]]
					this_country.setStyle({color: country_color(row["usd_2009"])})

			Finch.listen()
		})




Finch.route "/:country_iso2", (bindings) ->
	App.zoom_to bindings.country_iso2


Finch.route "[/:country_iso2]/:year", (bindings) ->
	country_name = App.layers[bindings.country_iso2].feature.properties.name
	if country_name is "Central African Republic"
		country_name = "Central African Rep."
	App.details_for country_name, bindings.year