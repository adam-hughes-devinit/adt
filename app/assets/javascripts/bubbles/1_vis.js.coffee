
class BubbleChart
  constructor: (data) ->
    @data = data
    @width = 940
    @height = 600
    @readable = d3.format(",.0f")

    
    $("body").append("<div class='tooltip' id='bubbletooltip' style='position:absolute;background-color: rgb(255, 255, 255); border: 1px solid rgb(128, 128, 128); opacity: 0.9; padding: 1px 5px;'></div>");
    window.hideTooltip = () ->
      $('#bubbletooltip').hide();
    window.hideTooltip();
    window.updatePosition = (event) ->
      xOffset = 20;
      yOffset = 10;
      ttw = $("#bubbletooltip").width();
      tth = $("#bubbletooltip").height();
      wscrY = $(window).scrollTop();
      wscrX = $(window).scrollLeft();
      curX = if (document.all) then event.clientX + wscrX else event.pageX;
      curY = if (document.all) then event.clientY + wscrY else event.pageY;
      ttleft = if ((curX - wscrX + xOffset*2 + ttw) > $(window).width()) then curX - ttw - xOffset*2 else curX + xOffset;
      if ttleft < wscrX + xOffset
        ttleft = (wscrX + xOffset);
      tttop = if ((curY - wscrY + yOffset*2 + tth) > $(window).height()) then curY - tth - yOffset*2 else curY + yOffset;
      if tttop < wscrY + yOffset
        tttop = curY + yOffset;
      $("#bubbletooltip").css('top', tttop + 'px').css('left', ttleft + 'px');
    window.showTooltip = (content, event) ->
      $('#bubbletooltip').html(content);
      $('#bubbletooltip').show();
      window.updatePosition(event);
      

    # locations the nodes will move towards
    # depending on which view is currently being
    # used
    @center = {x: @width / 2, y: @height / 2}
    @year_centers = {
      "2000": {x: 200, y: @height / 2},
      "2001": {x: 250, y: @height / 2},
      "2002": {x: 300, y: @height / 2},
      "2003": {x: 350, y: @height / 2},
      "2004": {x: 400, y: @height / 2},
      "2005": {x: 450, y: @height / 2},
      "2006": {x: @width-450, y: @height / 2},
      "2007": {x: @width-400, y: @height / 2},
      "2008": {x: @width-350, y: @height / 2},
      "2009": {x: @width-300, y: @height / 2},
      "2010": {x: @width-250, y: @height / 2},
      "2011": {x: @width-200, y: @height / 2},
    }
    @flow_centers = {
      "ODA-like" : {x:300, y: @height / 2},
      "Vague (Official Finance)" : {x:300, y: @height / 2},
      "OOF-like" : {x:300, y: @height / 2},
      "CA -Gov" : {x: @width / 2, y: @height / 2},
      "CA +Gov" : {x: @width / 2, y: @height / 2},
      "FDI -Gov" : {x: @width / 2, y: @height / 2},
      "FDI +Gov" : {x: @width / 2, y: @height / 2},
      "JV -Gov" : {x: @width / 2, y: @height / 2},
      "JV +Gov" : {x: @width / 2, y: @height / 2},
      "Military" : {x:@width-300, y: @height / 2},
      "NGO Aid" : {x: @width / 2, y: @height / 2},
      "Vague (Com)" : {x: @width / 2, y: @height / 2},
      "Official Investment" : {x:300, y: @height / 2}
    }
    console.log @flow_centers
    # used when setting up force and
    # moving around nodes
    @layout_gravity = -0.01
    @damper = 0.1

    # these will be set in create_nodes and create_vis
    @vis = null
    @nodes = []
    @force = null
    @circles = null

    @fill_color = d3.scale.ordinal()
    .domain(["ODA-like","Vague (Official Finance)","OOF-like","Official Investment","NGO Aid","CA -Gov","CA +Gov","JV -Gov","JV +Gov","FDI -Gov","FDI +Gov","Vague (Com)","Military"])
    .range(["#3182bd","#65a5d3","#a5cae4","#9784e0","#5ce5cd","#5edf73","#49a959","#f7fc76","#f9e21b","#fd8d3c","#e6550d","#fe4444","#ff0000"]);

    # use the max total_amount in the data as the max in the scale's domain
    max_amount = d3.max(@data, (d) -> parseInt(d.usd_defl))
    @radius_scale = d3.scale.pow().exponent(0.5).domain([0, max_amount]).range([2, 50])
    
    this.create_nodes()
    this.create_vis()

  # create node objects from original data
  # that will serve as the data behind each
  # bubble in the vis, then add each node
  # to @nodes to be used later
  create_nodes: () =>
    @data.forEach (d) =>
      node = {
        id: d.project_id
        radius: @radius_scale(parseInt(d.usd_defl))
        value: parseInt(d.usd_defl)
        name: d.title
        group: d.flow_class
        year: d.year
        recipient: d.recipient_condensed
        sector: d.crs_sector_name
        x: Math.random() * 900
        y: Math.random() * 800
      }
      @nodes.push node

    @nodes.sort (a,b) -> b.value - a.value


  # create svg at #vis and then 
  # create circle representation for each node
  create_vis: () =>
    @vis = d3.select("#vis2").append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .attr("id", "svg_vis")
    
    @legend = d3.select("div#legend").append("svg")
      .attr("width", @width/4)
      .attr("height", @height-55)
      .attr("id", "svg_vis")

    @circles = @vis.selectAll("circle")
      .data(@nodes, (d) -> d.id)

    # used because we need 'this' in the 
    # mouse callbacks
    that = this

    # radius will be set to 0 initially.
    # see transition below
    @circles.enter().append("circle")
      .attr("r", 0)
      .attr("fill", (d) => @fill_color(d.group))
      .attr("stroke-width", 1)
      .attr("stroke", (d) => d3.rgb(@fill_color(d.group)).darker())
      .attr("id", (d) -> "#{d.id}")
      .style("curser","pointer")
      .on("mouseover", (d,i) -> that.show_details(d,i,this))
      .on("mouseout", (d,i) -> that.hide_details(d,i,this))
      .on("click", (d,i) -> that.open_project_in_new_window(d,i,this))

    # Fancy transition to make bubbles appear, ending with the
    # correct radius
    @circles.transition().duration(2000).attr("r", (d) -> d.radius)


  # Charge function that is called for each node.
  # Charge is proportional to the diameter of the
  # circle (which is stored in the radius attribute
  # of the circle's associated data.
  # This is done to allow for accurate collision 
  # detection with nodes of different sizes.
  # Charge is negative because we want nodes to 
  # repel.
  # Dividing by 8 scales down the charge to be
  # appropriate for the visualization dimensions.
  charge: (d) ->
    -Math.pow(d.radius, 2.0) / 8

  # Starts up the force layout with
  # the default values
  start: () =>
    @force = d3.layout.force()
      .nodes(@nodes)
      .size([@width, @height])

  # Sets up force layout to display
  # all nodes in one circle.
  display_group_all: () =>
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_center(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()
    
    max_amount = d3.max(@data, (d) -> parseInt(d.usd_defl))
    min_amount = d3.min(@data, (d) -> parseInt(d.usd_defl))
    exampleArr = [{"r":@radius_scale(d3.round(max_amount,-9)),"amount":@readable(d3.round(max_amount,-9))},{"r":@radius_scale(d3.round(max_amount/2,-9)),"amount":@readable(d3.round(max_amount/2,-9))},{"r":@radius_scale(d3.round(max_amount/10,-7)),"amount":@readable(d3.round(max_amount/10,-7))},{"r":@radius_scale(d3.round(min_amount*1000,-2)),"amount":@readable(d3.round(min_amount*1000,-2))}]       
    @legend.append("text")
      .attr("x",0)
      .attr("y",20)
      .attr("id","legendtitle")
      .attr("style","font-size:18;text-decoration:underline")
      .text("Bubble Area - Project Value")
    @legend.selectAll("circle#example")
      .data(exampleArr)
      .enter().append("circle")
      .attr("cx",(d) -> 5 + d.r)
      .attr("cy",(d) -> 140- d.r)
      .attr("r",(d) -> d.r)
      .attr("fill","white")
      .attr("style","stroke-dasharray: 2, 2")
      .attr("stroke","black")
      .attr("fill-opacity","1.0")
      .attr("id","example")
      .attr("stroke-opacity","0.5")
    @legend.selectAll("text#example")
      .data(exampleArr)
      .enter().append("text")
      .attr("x", (d) -> 5 + 2*d.r)
      .attr("y", (d) -> 145-d.r)
      .attr("id","example")
      .text((d) ->return "-----$"+d.amount)
    @legend.append("text")
      .attr("x",60)
      .attr("y",160)
      .attr("id","example")
      .text("Constant 2009 USD")
    @legend.append("text")
      .attr("x",0)
      .attr("y",190)
      .attr("id","legendtitle")
      .attr("style","font-size:18;text-decoration:underline")
      .text("Bubble Color - Flow Class")
    @legend.selectAll("rect#example")
    .data(d3.keys(@flow_centers))
    .enter()
    .append("rect")
    .attr("fill",(d) => @fill_color(d))
    .attr("x",0)
    .attr("y",(d,i) -> 210+i*25)
    .attr("width",20)
    .attr("id",(d) -> d)
    .attr("height",20)
    .attr("rx",5)
    .attr("ry",5)
    .attr("stroke","black")
    .attr("stroke-width",1);
    @legend.selectAll("text#flowexamples")
    .data(d3.keys(@flow_centers))
    .enter()
    .append("text")
    .attr("x",25)
    .attr("y",(d,i) -> 225+i*25)
    .attr("id", "flowexamples")
    .text((d) -> d);

    this.hide_years()
    this.hide_flows()

  # Moves all circles towards the @center
  # of the visualization
  move_towards_center: (alpha) =>
    (d) =>
      d.x = d.x + (@center.x - d.x) * (@damper + 0.02) * alpha
      d.y = d.y + (@center.y - d.y) * (@damper + 0.02) * alpha

  # sets the display of bubbles to be separated
  # into each year. Does this by calling move_towards_year
  display_by_year: () =>
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_year(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()

    this.display_years()
    this.hide_flows()

  # move all circles to their associated @year_centers 
  move_towards_year: (alpha) =>
    (d) =>
      target = @year_centers[d.year]
      d.x = d.x + (target.x - d.x) * (@damper + 0.02) * alpha * 1.1
      d.y = d.y + (target.y - d.y) * (@damper + 0.02) * alpha * 1.1

  # Method to display year titles
  display_years: () =>
    years_x = {"2000":80,"2011":@width-50}
    years_data = d3.keys(years_x)
    years = @vis.selectAll(".years")
      .data(years_data)

    years.enter().append("text")
      .attr("class", "years")
      .attr("x", (d) => years_x[d] )
      .attr("y", 100)
      .attr("text-anchor", "middle")
      .text((d) -> d)

  # Method to hide year titles
  hide_years: () =>
    years = @vis.selectAll(".years").remove()

  #Flow Class
  display_by_flow: () =>
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_flow(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()

    this.display_flows()
    this.hide_years()

  # move all circles to their associated @flow_centers 
  move_towards_flow: (alpha) =>
    (d) =>
      target = @flow_centers[d.group]
      d.x = d.x + (target.x - d.x) * (@damper + 0.02) * alpha * 1.1
      d.y = d.y + (target.y - d.y) * (@damper + 0.02) * alpha * 1.1

  # Method to display flow titles
  display_flows: () =>
    flows_x = {"Official":200, "Unofficial":@width/2,"Military":@width-200}
    flows_data = d3.keys(flows_x)
    flows = @vis.selectAll(".flows")
      .data(flows_data)

    flows.enter().append("text")
      .attr("class", "flows")
      .attr("x", (d) => flows_x[d] )
      .attr("y", 100)
      .attr("text-anchor", "middle")
      .text((d) -> d)

  # Method to hide flow titles
  hide_flows: () =>
    flows = @vis.selectAll(".flows").remove()

  show_details: (data, i, element) =>
    d3.select(element).attr("stroke", "black")
    content = "<span class=\"tooltiptext\">Title:</span><span class=\"value\"> #{data.name}</span><br/>"
    content +="<span class=\"tooltiptext\">Amount:</span><span class=\"value\"> $#{@readable(data.value)}</span><br/>"
    content +="<span class=\"tooltiptext\">Recipient:</span><span class=\"value\"> #{data.recipient}</span><br/>"
    content +="<span class=\"tooltiptext\">Year:</span><span class=\"value\"> #{data.year}</span><br/>"
    content +="<span class=\"tooltiptext\">Flow Class:</span><span class=\"value\"> #{data.group}</span><br/>"
    content +="<span class=\"tooltiptext\">Sector:</span><span class=\"value\"> #{data.sector}</span></br>"
    content +="<span class=\"tooltiptext\">*Click to view project page</span>"
    showTooltip(content,d3.event)

  hide_details: (data, i, element) =>
    d3.select(element).attr("stroke", (d) => d3.rgb(@fill_color(d.group)).darker())
    hideTooltip()
    
  open_project_in_new_window: (data, i, element) =>
    window.open "/projects/" + data.id


root = exports ? this

$ ->
  chart = null

  render_vis = (csv) ->
    filteredcsv = csv.filter (d) -> d.year>1999 && d.year<2012 && d.usd_defl!="" && d.flow_class!="" && d.crs_sector_name!=""
    chart = new BubbleChart filteredcsv
    chart.start()
    root.display_all()
  root.display_all = () =>
    chart.display_group_all()
  root.display_year = () =>
    chart.display_by_year()
  root.display_flow = () =>
    chart.display_by_flow()
  root.toggle_view = (view_type) =>
    if view_type == 'year'
      root.display_year()
    else
      if view_type == 'flow'
        root.display_flow()
      else
        root.display_all()


  page = 1
  page_size = 10
  max_count = 2400
  percent_loaded = 0
  percent_step = 100 / ( max_count/page_size )
  csv = []
  $('#loading-bar .progress .bar').css("width", "1%")
  load_projects = (page, page_size, percent_loaded,percent_step) ->
    # console.log "Getting #{page_size} projects from page #{page}"
    d3.csv "/projects.csv?active_string=Active&page=#{page}&max=#{page_size}", (data) ->
      percent_loaded += percent_step
      $('#loading-bar .progress .bar').css("width", "#{percent_loaded}%")
      csv = csv.concat(data)
      if data.length >= page_size
        page +=1
        load_projects(page, page_size, percent_loaded, percent_step)
      else
        $('#loading-bar').css("width", "100%")
        console.log "Found #{csv.length} active projects"
        render_vis csv
        $('#loading-bar').slideUp().remove()
  
  load_projects_all_at_once = () ->
     d3.csv "/projects.csv?active_string=Active", (csv) ->
        $('#loading-bar').css("width", "100%")
        console.log "Found #{csv.length} active projects"
        render_vis csv
        $('#loading-bar').slideUp().remove()      
  
  # load_projects page, page_size, percent_loaded, percent_step
  load_projects_all_at_once()

