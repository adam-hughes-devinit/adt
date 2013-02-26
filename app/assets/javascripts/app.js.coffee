Array.prototype.getUnique = () ->
  u = {}
  a = []
  for item, i in this
    if u.hasOwnProperty item
      continue
    a.push item
    u[item] = 1
  a



String.prototype.pluralize = (count, plural) ->
  if count == 1  
    this
  else 
    if !plural
      plural = this + 's'
    plural


@remove_fields = (link) ->
  if (confirm("Are you sure?") )
    @changed = true
    $(link).prev("input[type=hidden]").val("1");
    $(link).closest(".fields").slideUp();


@add_fields = (link, association, content) ->
  @changed = true
  new_id = new Date().getTime();
  regexp = new RegExp("new_" + association, "g")
  new_content = $(content.replace(regexp, new_id))
  $(link).parent().after(new_content.hide())
  new_content.slideDown()
