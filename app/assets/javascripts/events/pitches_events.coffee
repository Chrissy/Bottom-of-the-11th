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
    self.updateCal()
    select2.buildWithRivals(initPlayer)
  )

  select2.onChange( (self) -> 
    self.updateCalWithCrossReferents()
  )  
  
  calendar.onChange( (self) -> 
    calendar.draw()
  )


  
  