

$('.organization_merger').typeahead([
	{
		name: "organizations"
		remote: "/organizations/typeahead?search=%QUERY"
		template: $('#typeahead_template').html()
		engine: typeahead_engine
		limit: 10,
	}
]).on("change typeahead:selected", (e, datum) ->
		# console.log datum
		detail = $(this).parent().parent().siblings(".organization_merger_details")
		detail.html('')
		if datum? 		
			$.get "/organizations/#{datum.value}.json", (data) ->
				html = "<h4>#{data.to_english}</h4>"
				html += "<p>Projects:<ul class=''>"
				(html += "<li><a href='/projects/#{p.id}'>#{p.to_english}</a></li>" for p in data.projects)
				html += "</ul></p>"
				detail.html(html)
				offer_merge_if_both()
)
offer_merge_if_both = ->
	real_id = Number $("#real_organization").val()
	duplicate_id = Number $("#duplicate_organization").val()
	console.log "offer merge?", real_id, duplicate_id
	if real_id > 0 and duplicate_id > 0
		offer_merge()
	else
		hide_merge()
	
offer_merge = ->
	console.log("offer merge")
	$("#offer_merge").slideDown()

hide_merge = ->
	$("#offer_merge").slideUp()

