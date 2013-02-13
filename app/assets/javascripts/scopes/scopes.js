var Scope = Backbone.Model.extend({})

var ScopeTable = Backbone.View.extend({
	el: $('#scope_div'),

	tagName: 'table',
	className: 'table table-hover scope-table',
	intialize: function() {
		this.render()
	},

	render: function(){
		console.log("rendering")
		$(this.el).html("<p>Rendered!</p>")

	}

	})

var Scopes = Backbone.Collection.extend({
	model: Scope,
	url: '/scopes'
	})


