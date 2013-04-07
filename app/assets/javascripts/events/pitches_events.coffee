initPlayer = 405395 #Albert Pujols

$ ->
  
  surface = new Surface
  calendar = new Calendar "cal-primary", surface
  select = new Select "#player-1", calendar

  calendar.setupForPlayer(initPlayer)

  select.changePlayer(initPlayer)
  
  select.onChange( (self) -> 
    self.updateCal()
  ) 
  
  calendar.onChange( (self) -> 
    calendar.draw()
  )


  
  