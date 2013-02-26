var app = app || {}

app.ScopeFilter = Backbone.Model.extend({
	defaults: {
		field: "field_name",
		values: ['value1', 'value2']
	},

	initialize: function() {
		console.log("initializing ScopeFilter", this);
	}
})