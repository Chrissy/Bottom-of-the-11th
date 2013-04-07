class window.Select

  constructor : (selector, calendar) ->
    @sel = $(selector).chosen()
    @cal = calendar
  
  changePlayer : (id) ->
    option = @sel.children('option').filter("[value='405395']")[0]
    @sel[0].selectedIndex = option.index
    @sel.trigger('liszt:updated')
    
  onChange : (func) ->
    self = @
    @sel.change( -> func(self))
    
  currentId : ->
    return @sel.val()
    
  updateCal : ->
    @cal.setupForPlayer(@currentId())