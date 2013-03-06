@App = @App || {}


Finch.route "/", (bindings, childCallback) ->
	console.log "called home!"
	if !App.initialized()
		App.initialize(App.config.data.file)
	setTimeout(childCallback, 200)

Finch.route "[/]:x_axis", (bindings) ->
	console.log "called x-axis: #{bindings.x_axis}"
	x_axis = bindings.x_axis 
	App.make_with_new_x_axis("#{x_axis}")

Finch.listen()