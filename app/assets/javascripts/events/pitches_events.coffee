initPlayer = 405395 #Albert Pujols 
initPitcher = 453286 #Max Scherzer

$ ->
  
  surface = new Surface
  calendar = new Calendar "cal-primary", surface
  select = new Select "nav", calendar
  select2 = new Select "nav", calendar
  
  select.onChange( (self) -> 
    if select2.sel.val() != ""
       calendar.setupDatesForRivalry(select.sel.val(), select2.sel.val())
    else 
      select2.buildWithRivals(initPlayer, initPitcher)
      self.updateCal()
  )

  select2.onChange( (self) -> 
    calendar.setupDatesForRivalry(select.sel.val(), select2.sel.val())
  )  
  
  calendar.onChange( (self) -> 
    calendar.draw()
  )

  select.buildWithAll(initPlayer).promise().then( ->
    select2.buildWithRivals(initPlayer, initPitcher).promise().then( ->
      calendar.setupDatesForRivalry(select.sel.val(), select2.sel.val())
    )
  )
