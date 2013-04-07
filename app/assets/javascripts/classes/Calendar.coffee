class window.Calendar
  autoSelectNumber : 5
  
  constructor: (@id, surface) ->
    @surface = surface
    @cal = new Kalendae("cal-primary",
      viewStartDate : "04/06/2012",
      mode: 'multiple'
    )
    
  setupForPlayer : (playerId) ->
    self = @
    console.log(playerId)
    @setupDatesForPlayer(playerId).promise().then( ->
      self.selectLast(@autoSelectNumber).promise().then( ->
        self.draw(@surface)
      )
    )

  setupDatesForPlayer : (playerId) ->
    @playerId = playerId
    cal = @cal 
    self = @
    @cal.blackout = @getDatesForPlayer(playerId).promise().then((dates) ->
      cal.blackout = (dateToCheck) ->
        self.returnOppositeDate(dateToCheck, dates)
      cal.draw()
    )
  
  selectLast : ->
    return "setup blackout dates first" if !@playerId
    self = @
    @getDatesForPlayer(@playerId).promise().then((dates) ->
      moments = []
      last_dates = dates.dates.reverse().slice(0, self.autoSelectNumber)
      for date in last_dates
        moments.push(Kalendae.moment("#{date[0]},#{date[1]},#{date[2]}", "YYYYMD"))
      self.cal.setSelected(moments)
      self.cal.viewStartDate = moments[0]
      self.cal.draw()
    )
  
  draw : ->
    self = @
    dates = @getSelectedDatesAsArray()
    datesString = ""
    for date in dates
      datesString += "&dates[]=#{date}"
    $.ajax(
      url: "/pitches/get.json?pid=#{@playerId + datesString}"
    ).done((data) ->
      self.surface.draw(data)
    )
    
  getSelectedDatesAsArray : ->
    rawDates = @cal.getSelectedRaw()
    formattedDates = rawDates.map (date) -> date.format("YYYYMMDD")
    return formattedDates
    
  getDatesForPlayer : (pid) ->
    $.get("/pitches/dates.json?pid=#{pid}").then(
      (dates) -> return dates
      -> return "could not find dates"
    )
    
  returnOppositeDate : (dateToCheck, dates) ->
    for date in dates.dates
      return false if dateToCheck.format("YYYY,M,D") == "#{date[0]},#{date[1]},#{date[2]}"
    return true;
    
  onChange : (func) ->
    self = @
    @cal.subscribe('change', -> func(self))
    