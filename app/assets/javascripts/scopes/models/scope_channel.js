
var app = app || {}

app.ScopeChannel = Backbone.Model.extend({
	defaults: {
		scope_filters: []
	},

	initialize: function () {
		this.set('scope_filters', [new app.ScopeFilter] )
		console.log("initializing ScopeChannel", this)
	}
})