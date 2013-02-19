
var app = app || {}

app.ScopeView = Backbone.View.extend({
	el: $("#scope"),
	template: _.template(
	"<h1><%= name %></h1>" +
	"<% channels.forEach(function (c) { %>" +
		"<ul class='channel unstyled'>" +
			"<% c.forEach(function(i) { %>" +
				"<li class='field'>" +
					"<b>" +
						"<%= i.field %>" +
					"</b>: " +
					"<span class='scope-show-field'>" +
						"<%= i.values.join(', ') %>" +
					"</span>" +
					"<input class='scope-edit-field' type='text' value='" +
						"<%= i.values.join(', ') %>" +
					"'/>" +
				"</li>" +
			"<% }) %>" +
		"</ul>"+
	"<% }) %>" +
	"<p class='field'>" +
		"<span class='scope-show-field'>" +
			"<%= symbol %>" +
		"</span>" +
		"<input type='text' class='scope-edit-field' value='" +
			"<%= symbol %>" +
		"'/>" +
	"</p>" +
	"<p> <%= description %> </p>"
	),

	tagName: "div",
	className: "scope",

	events: {
		"blur .field.editing" : "close",
		"click .field" : "edit",
		"keypress .scope-edit-field" : "update_on_enter"

	},

	initialize: function() {
		_.bindAll(this, "render")
		console.log("initializing scopeview", this )
		this.render()

	},

	render: function() {
		console.log("rendering ScopeView", this, "to", this.$el)
		this.$el.html( this.template( this.attributes ) );
		return this;
	},

	edit: function(e) {
		console.log("editing -- this:", this, ", event: ", e)
		$field = $(e.currentTarget)
		$field.addClass("editing")
		$field.children('.scope-show-field').slideUp(100,function(){
			$field.children('.scope-edit-field').show().focus()
		})
	},

	close: function(e) {
		console.log("closing -- this:", this, ", event: ", e)
		$field = $(".editing")
		$field.removeClass("editing")
		$field.children('.scope-edit-field').slideUp(100, 
			function() {
				$show = $field.children('.scope-show-field')
				$show.html($field.children('.scope-edit-field').val())
				$show.show()
			}
		)
	},

	// If you hit `enter`, we're through editing the item.
    update_on_enter: function( e ) {
      console.log("keypress: ", e.which, " this: ", this)

      if ( e.which === ENTER_KEY ) {
        this.close();
      }
    }, 

})