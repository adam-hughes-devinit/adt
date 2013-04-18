Array.prototype.getUnique = () ->
  u = {}
  a = []
  for item, i in this
    if u.hasOwnProperty item
      continue
    a.push item
    u[item] = 1
  a


@nice_money = (amount) ->
  if d3?
    if 1000 >= amount 
      "#{d3.format("0,r")(d3.round(amount,0))}"
    else if 1000000 > amount >= 1000
      "#{d3.round((amount/1000),0)} K"
    else if 1000000000 > amount >= 1000000
      "#{d3.round((amount/1000000),1)} M"
    else if amount >= 1000000000
      "#{d3.format("0,r")(d3.round((amount/1000000000),2))} B"
    else
      amount
  else
    console.log "nice_money requires D3"
    amount


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
