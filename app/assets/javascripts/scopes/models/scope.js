
var app = app || {}

app.Scope = Backbone.Model.extend({
	defaults: {
		name: "Scope Name",
		symbol: "scope_symbol",
		description: "This is the default Scope description.",
		scope_channels: []
	},

	initialize: function() {
		this.set('scope_channels', [ new app.ScopeChannel ])
		console.log("initializing Scope", this)	
	}
})