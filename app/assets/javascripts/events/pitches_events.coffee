$ ->
  
  surface = new Surface
  calendar = new Calendar "cal-primary", surface
  select = new Select ".select-1", calendar
  select2 = new Select ".select-2", calendar
  displayType = $("#display-type").chosen()
  presets = $("#presets").chosen()

  calendar.onChange( (self) -> 
    calendar.draw()
  )

  select.buildWithAll("first").promise().then( ->
    select2.buildWithRivals(0).promise().then( ->
      select.setup()
    )
  )

  select.onChange( (self) ->
    self.opponentSelect().buildWithRivals()
    self.setup()
  )

  select2.onChange( (self) ->
    self.setup()
  )

  displayType.change( (self) ->
    $('.select-1').first().data("select").setup()
  )