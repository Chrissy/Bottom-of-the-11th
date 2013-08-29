initPlayer = 405395 #Albert Pujols 
#612672

$ ->
  
  surface = new Surface
  calendar = new Calendar "cal-primary", surface
  select = new Select "nav", calendar
  select2 = new Select "nav", calendar

  select.buildWithAll(initPlayer)
  select2.buildWithRivals(initPlayer)

  calendar.setupForPlayer(initPlayer)
  
  select.onChange( (self) -> 
    if select2.sel.val() != ""
       calendar.setupDatesForRivalry(select.sel.val(), select2.sel.val())
    else 
      self.updateCal()
      select2.buildWithRivals(initPlayer)
  )

  select2.onChange( (self) -> 
    calendar.setupDatesForRivalry(select.sel.val(), select2.sel.val())
  )  
  
  calendar.onChange( (self) -> 
    calendar.draw()
  )


  
  