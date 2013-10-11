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
