$( ->
  $('.dropdown-toggle').dropdown()


  # Replace references to projects (#\d+) with hyperlinks:
  to_project_link = (id) ->
    "<a class='project_link project_link_#{id}' data-project-id=#{id} href='/projects/#{id}' target='_blank' >##{id}</a>"
  
  initialize_project_links = ->
    ids = []  
    $('.project_link').each( -> 
      id = $(this).attr("data-project-id")
      if ids.indexOf(id) is -1
        ids.push(id)      
    )

    ids.forEach( (id) ->
      $.get("/projects/#{id}.json", (data) ->
        links = $(".project_link.project_link_#{id}")
        links.attr("title", data["to_english"])
        links.tooltip()
        )
    )
  id_ref_finder = /(#)(\d+)/g
  duplicate_finder = /(duplicate\s+\w+)\s+(\d+)/gi
  
  $('body a,p,i,em,strong,b,label,h1,h2,h3,h4,h5,h6').filter( ->
      this_text = $(this).text()
      this_text.match(/#\d+/) || this_text.match(duplicate_finder) ;
  ).each(->
    html = $(this).html()
    new_html = html
      .replace(id_ref_finder, to_project_link("$2"))
      .replace(duplicate_finder, "$1 #{to_project_link("$2")}")
    $(this).html(new_html)
  )

  initialize_project_links()

)
Array.prototype.getUnique = () ->
  u = {}
  a = []
  for item, i in this
    if u.hasOwnProperty item
      continue
    a.push item
    u[item] = 1
  a

@typeahead_engine = 
  compile: (template) ->
    compiled = _.template(template)
    {render: (context) -> compiled(context)}


@nice_money = (amount, options={}) ->
  # Props to akmiller for original code -- I'm using it all the time though so hosting it here.
  full_label = options?.full_label || false
  if d3?
    if 1000 >= amount 
      label = ""
      money = d3.format("0,r")(d3.round(amount,0))
    else if 1000000 > amount >= 1000
      label = (if full_label then "Thousand" else "K" )
      money = d3.round((amount/1000),0)
    else if 1000000000 > amount >= 1000000
      label = (if full_label then "Million" else "M")
      money = d3.round((amount/1000000),1)
    else if amount >= 1000000000
      label = (if full_label then "Billion" else "B")
      money = d3.format("0,r")(d3.round((amount/1000000000),2))
    else
      label = ""
      money = amount

    money + " " + label
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
  new_html = content.replace(regexp, new_id)
  # console.log(new_html)
  new_content = $(new_html)
  # console.log new_content
  $(link).parent().after(new_content.hide())
  new_content.slideDown()
