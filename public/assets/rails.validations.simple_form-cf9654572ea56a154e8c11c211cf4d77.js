/*
  Client Side Validations - SimpleForm - v2.0.0
  https://github.com/dockyard/client_side_validations-simple_form

  Copyright (c) 2012 DockYard, LLC
  Licensed under the MIT license
  http://www.opensource.org/licenses/mit-license.php
*/
((function(){ClientSideValidations.formBuilders["SimpleForm::FormBuilder"]={add:function(a,b,c){return this.wrappers[b.wrapper].add.call(this,a,b,c)},remove:function(a,b){return this.wrappers[b.wrapper].remove.call(this,a,b)},wrappers:{"default":{add:function(a,b,c){var d,e;return d=a.parent().find(""+b.error_tag+"."+b.error_class),e=a.closest(b.wrapper_tag),d[0]==null&&(d=$("<"+b.error_tag+"/>",{"class":b.error_class,text:c}),e.append(d)),e.addClass(b.wrapper_error_class),d.text(c)},remove:function(a,b){var c,d;return d=a.closest(""+b.wrapper_tag+"."+b.wrapper_error_class),d.removeClass(b.wrapper_error_class),c=d.find(""+b.error_tag+"."+b.error_class),c.remove()}},bootstrap:{add:function(a,b,c){var d,e,f;return d=a.parent().find(""+b.error_tag+"."+b.error_class),d[0]==null&&(f=a.closest(b.wrapper_tag),d=$("<"+b.error_tag+"/>",{"class":b.error_class,text:c}),f.append(d)),e=a.closest("."+b.wrapper_class),e.addClass(b.wrapper_error_class),d.text(c)},remove:function(a,b){var c,d,e;return d=a.closest("."+b.wrapper_class+"."+b.wrapper_error_class),e=a.closest(b.wrapper_tag),d.removeClass(b.wrapper_error_class),c=e.find(""+b.error_tag+"."+b.error_class),c.remove()}}}}})).call(this);