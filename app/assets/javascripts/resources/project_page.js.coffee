
$('.resource-tooltip').tooltip()
$('#new_resource').typeahead
  name: "resources"
  remote: "/resources/typeahead?search=%QUERY"
  template: $("#typeahead_template").html()
  engine: typeahead_engine
  limit: 20


pinned_resources_path = "#{window.location.pathname}/pinned_resources"
unlink_button = "<a  class='pull-right btn btn-small btn-danger unlink-resource'>Unlink</a>"

@unlink_resource = ->
  if confirm "Are you sure you want to remove this resource? (No undo!)"
    resource = $(this).closest(".resource")
    resource_id = resource.attr("data-resource-id")
    console.log resource, resource_id
    $.ajax 
      url: pinned_resources_path + "/" + resource_id
      method: "DELETE"
      success: (response) ->
        if response["status"] == "success"
          resource.remove()

add_resource = ->
  this_input = $('#new_resource')
  this_input.slideUp() 
  resource_id = this_input.val()

  $.post(pinned_resources_path + ".json", {resource_id: resource_id}, (response) ->
    if response["status"] == "success"
      $("#no_resources").remove()
      template_data = 
        resource: response["resource"]
        unlink_button: unlink_button
        resource_id: resource_id

      new_resource = _.template($("#resource-template").html(), template_data)
      $("#resources").append(new_resource)

      this_input.val('')
      $('.unlink-resource').off().click(unlink_resource)
    this_input.slideDown()

  )
$('div.project_resources_id').each(->
  group = $(this)
  value = $(this).find('input').val()
  parent = $(this).parent()
  parent.attr("data-resource-id", value)
  # group.remove()
)

$('#add_resource').click add_resource
$('.resource p:last-child').append(unlink_button)
$('.unlink-resource').click(unlink_resource)