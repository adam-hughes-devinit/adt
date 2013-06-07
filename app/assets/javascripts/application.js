// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require ./underscore/index
//= require ./app
//= require rails.validations
//= require bootstrap_teaser
//= require ./twitter_typeahead/index
$(function() {
$('#header_search').typeahead([
	{
		name: "contents",
		remote: "/contents/typeahead?search=%QUERY",
		template: $('#typeahead_template').html(),
		engine: typeahead_engine,
		limit: 4,
	},
	{
		name: "projects",
		remote: "/projects/typeahead?search=%QUERY",
		template: $('#typeahead_template').html(),
		engine: typeahead_engine,
		limit: 8,
	},
	{
		name: "resources",
		remote: "/resources/typeahead?search=%QUERY",
		template: $('#typeahead_template').html(),
		engine: typeahead_engine,
		limit: 8,
	},

	]).on("typeahead:selected", function(e, datum) {		
		window.location = datum.target
	}).on("keyup", function(e) {
		if (e.which == 13 && $("*:focus").is("#header_search")) {
			var target;
			var value = $(this).val()
			var tt_target = String($('.tt-is-under-cursor').children().attr("data-target"))
			alert(tt_target)
			if (tt_target!= 'undefined') {
				target = tt_target
			}
			else if (Number(value)) {
				target = "/projects/" + value
			}
			else {
				target = "/projects?search=" + value
			}
			window.location = target
		}
	})
})
