initPlayer = 405395 #Albert Pujols 
#initPitcher = 453286 #Max Scherzer
initPitcher = 434378 #Justin Verlander

$ ->
  
  surface = new Surface
  calendar = new Calendar "cal-primary", surface
  select = new Select "nav", calendar
  select2 = new Select "nav", calendar
  
  select.onChange( (self) -> 
    if select2.sel.val() != ""
       calendar.setupDatesForRivalry(select.sel.val(), select2.sel.val())
    else 
      select2.buildWithRivals(initPlayer, initPitcher).promise().then( ->
        calendar.setupDatesForRivalry(select.sel.val(), select2.sel.val())
      )
  )

  select2.onChange( (self) -> 
    calendar.setupDatesForRivalry(select.sel.val(), select2.sel.val())
    select.buildWithRivals(select2.sel.val(), initPlayer)
  )  
  
  calendar.onChange( (self) -> 
    calendar.draw()
  )

  select.buildWithAll(initPlayer).promise().then( ->
    select2.buildWithRivals(initPlayer, initPitcher).promise().then( ->
      calendar.setupDatesForRivalry(select.sel.val(), select2.sel.val())
    )
  )
