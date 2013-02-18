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