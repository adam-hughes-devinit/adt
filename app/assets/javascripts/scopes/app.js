
var app = app || {}
var ENTER_KEY = 13;

$(function(){
	  _.templateSettings.evaluate =    /\{\[(.+?)\]\}/g,
      _.templateSettings.interpolate = /\{\{(.+?)\}\}/g


	app.sv = new app.ScopeView({ model: new app.Scope})

})