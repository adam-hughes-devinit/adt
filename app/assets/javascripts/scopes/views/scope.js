var app = app || {}

app.ScopeView = Backbone.View.extend({
	el: '#scopes',
	tagName: "#div",
	className: "scope_view",
	model: app.Scope,
	channel_template: $("#scope_channel_template").html(),
	template: $("#scope_template").html(),
	
	events: {
		'click .scope-editable' : 'edit',
		'blur .scope-edit' : 'close',
		'keypress .scope-edit' : 'update_on_enter',
		'click #add_scope_channel' : 'add_channel'
	},

	initialize: function() {
		console.log("initializing ScopeView", this)
		this.render()
		return this
	},

	render: function() {
		console.log("rendering ScopeView", this)
		var template = _.template( $("#scope_template").html(), this.model.attributes );
		this.$el.html(template)
		_.each(this.model.attributes.scope_channels, function(channel) {
			var channel_template = _.template($("#scope_channel_template").html(), channel.attributes)
			this.$el.append(channel_template)
		})
		return this
	},

	add_channel: function (e) {
		console.log("ADD CHANNEL")
		e.preventDefault();
		this.model.attributes.scope_channels.push(new app.ScopeChannel)
		this.render()		
		return this
	},

	edit: function(e) {
		console.log("EDIT e:", e, 'this:', this)
		$t = $(e.currentTarget);
		$t.hide()
		$t.siblings('.scope-edit').show().focus()
	},

	close: function(e) {
		console.log("CLOSE e:", e, "this:", this)
		$t = $('.scope-edit:visible');
		$t.hide()
		$t.siblings('.scope-editable').html($t.val()).show()
	},

	update_on_enter: function( e ) {
      if ( e.which === ENTER_KEY ) {
        this.close();
      }
    }

})