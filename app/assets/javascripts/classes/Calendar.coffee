class window.Calendar
  constructor: (@id, surface) ->
    @surface = surface
    @cal = new Kalendae("cal-primary",
      viewStartDate : "04/06/2012",
      mode: 'multiple'
    )
    
  setupForSelect : (select) ->
    self = @
    @setupDatesForPlayer(select.val()).promise().then((dates)  ->
      self.selectLast(dates, self.selectNum())
      self.draw(@surface)
    )

  setupDatesForPlayer : (playerId) ->
    self = @
    @playerId = playerId
    @getDatesForPlayer(playerId).promise().then((dates) ->
      self.setupDates(dates)
      return dates
    )

  setupDatesForRivalry : (playerId, opponentId) ->
    self = @
    @playerId = playerId
    @opponentId = opponentId
    @getDatesForRivalry(playerId, opponentId).promise().then((dates) ->
      self.setupDates(dates)
      self.selectLast(dates, self.selectNum())
      self.drawForRivalry()
    )

  setupDates : (dates) ->
    cal = @cal 
    self = @
    cal.blackout = (dateToCheck) ->
      self.returnOppositeDate(dateToCheck, dates)
    cal.draw()

  selectLast : (dates, numberOfDates) ->
    moments = []
    last_dates = dates.dates.reverse().slice(0, numberOfDates)
    for date in last_dates
      moments.push(Kalendae.moment("#{date[0]},#{date[1]},#{date[2]}", "YYYYMD"))
    @cal.setSelected(moments)
    @cal.viewStartDate = moments[0]
    @cal.draw()
  
  drawForRivalry : (pitcher_id) ->
    self = @
    dates = @getSelectedDatesAsArray()
    datesString = ""
    if @displayType() == "last-n-pitches"
      datesString = "&count=#{@displayValue()}"
    else
      for date in dates
        datesString += "&dates[]=#{date}"
    $.ajax(
      url: "/pitches/get.json?bid=#{self.opponentId}&pid=#{self.playerId}#{datesString}"
    ).done((data) ->
      self.surface.draw(data)
    )

  draw : ->
    self = @
    dates = @getSelectedDatesAsArray()
    datesString = ""
    if @displayType() == "last-n-pitches"
      datesString = "&count=#{@displayValue()}"
    else
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

  getDatesForRivalry : (player1, player2) ->
    $.get("/pitches/dates_faced.json?player1=#{player1}&player2=#{player2}").then(
      (dates) -> return dates
    )
    
  returnOppositeDate : (dateToCheck, dates) ->
    for date in dates.dates
      return false if dateToCheck.format("YYYY,M,D") == "#{date[0]},#{date[1]},#{date[2]}"
    return true;
    
  onChange : (func) ->
    self = @
    @cal.subscribe('change', -> func(self))

  displayValue : ->
    return $("#display-type").find("[value=#{ $("#display-type").val()} ]").attr("value")

  displayType : ->
    return $("#display-type").find("[value=#{ $("#display-type").val()} ]").attr("data-type")

  selectNum : ->
    return if @displayType() == 'last-n-pitches' then 0 else @displayValue()

    