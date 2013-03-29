
url = "#{window.location}/files"
$.get(url, (data) -> print_data(data) )

print_data = (data) ->
	console.log(data)
	# data = $.parseJSON(data)

	target = $('#files')
	if data.contents.length > 0
		menu = ("<li id='"+d.type+"-"+d.key+"'>
					<i class='"+ (if d.type is 'document' then 'icon-file' else 'icon-folder-close') + "'></i>
					<a href='http://aiddata-fs.herokuapp.com/documents/"+ d.key + "' onclick=\"App.navigate_to('"+d.type+"','"+d.key+"')\">" + 
					d.name + 
					"</a>
				</li>" for d in data.contents).join("") 
	else
		menu = "<li>(No files yet)</li>"
	# console.log menu
	target.html menu