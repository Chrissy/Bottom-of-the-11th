initPlayer = 453286 #Albert Pujols 
#initPitcher = 453286 #Max Scherzer
initPitcher = 405395 #Justin Verlander

$ ->
  
  surface = new Surface
  calendar = new Calendar "cal-primary", surface
  select = new Select "nav", calendar
  select2 = new Select "nav", calendar
  
  calendar.onChange( (self) -> 
    calendar.draw()
  )

  select.buildWithAll(initPlayer).promise().then( ->
    select2.buildWithRivals(initPlayer, 0).promise().then( ->
      calendar.setupForPlayer(initPlayer)
    )
  )
