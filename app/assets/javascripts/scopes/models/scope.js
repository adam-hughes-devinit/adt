
var app = app || {};

app.Scope = Backbone.Model.extend({
	
	defaults: {
		// Human-readable name
		name: "Scope name",
		// Internal reference (ruby symbol)
		symbol: "scope_name",
		// Short text description
		description: "This is the Scope default setting.",
		// OR-channels. A project can match any of these channels
		channels: [
			// A field can be ...?
			[
				// field-value objects. To pass a channel, a project must 
				// match all requirements in the channel
				{field: "active_string", values: ["true"]},
				{field: "verified_name", values: ["Checked", "Suspicious"]}
			]
		],
	},

	initialize: function() {
		console.log("initializing Scope", this)
	}

})

