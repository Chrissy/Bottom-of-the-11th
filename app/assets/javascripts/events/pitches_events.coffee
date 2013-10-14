$ ->
  
  surface = new Surface
  calendar = new Calendar "cal-primary", surface
  select = new Select "nav", calendar
  select2 = new Select "nav", calendar
  
  calendar.onChange( (self) -> 
    calendar.draw()
  )

  select.buildWithAll("first").promise().then( ->
    select2.buildWithRivals(0).promise().then( ->
      calendar.setupForSelect(select.sel)
    )
  )

  select.onChange( (self) ->
    self.opponentSelect().buildWithRivals()
    if self.opponentId() == "0"
      self.cal.setupForSelect(select.sel)
    else
      self.cal.setupDatesForRivalry(self.opponentId(), self.currentId())
  )

  select2.onChange( (self) ->
    self.cal.setupDatesForRivalry(self.currentId(), self.opponentId())
  )