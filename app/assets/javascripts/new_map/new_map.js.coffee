@log = (args...) -> (console.log a for a in args)

@App = @App || {}

App.nice_money = (amount) ->
	if 1000 >= amount 
		"#{d3.format("0,r")(d3.round(amount,0))}"
	else if 1000000 > amount >= 1000
		"#{d3.round((amount/1000),0)}K"
	else if 1000000000 > amount >= 1000000
		"#{d3.round((amount/1000000),1)}M"
	else if amount >= 1000000000
		"#{d3.format("0,r")(d3.round((amount/1000000000),2))}B"
	else
		amount

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
							country_name = e.target.feature.properties.name
							App.display_country(country_name)
							App.map.fitBounds(e.target.getBounds())
					}
			})

		countries.addTo(App.map)
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
	})