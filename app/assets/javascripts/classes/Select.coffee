class window.Select

  constructor : (parent, calendar) ->
    @select_element = $('<select class="player-select" data-placeholder="-----"/>')
    $(parent).append(@select_element)
    @sel = @select_element.chosen()
    @cal = calendar
    @select_element.data("select", @)
    @.initChangeEvent()

  buildWithRivals : (id, default_rival) ->
    self = @
    $.get("/pitches/players_faced.json?pid=#{id}").then(
      (data) ->
        self.build(data.player_ids)
        self.changePlayer(default_rival)
    )

  updateCalWithCrossReferents : ->
    @cal.setupDatesForRivalry(@currentId())

  buildWithAll : (selectedPlayer) ->
    self = @
    $.get("/pitches/all_players.json").then(
      (data) ->
        self.build(data.player_ids)
        self.changePlayer(selectedPlayer)
      -> 
        console.log "could not find players"
    )

  build : (players) ->
    optionsString = ''
    for player in players
      optionsString += "<option value=#{player.id}>#{player.last} #{player.first}</option>"
    @select_element.html(optionsString)  
    @sel.prepend("<option value='0'>--------</option>").trigger('liszt:updated')
  
  changePlayer : (id) ->
    option = @select_element.children('option').filter("[value='#{id}']")[0]
    @sel[0].selectedIndex = option.index
    @sel.trigger('liszt:updated')
    
  initChangeEvent : ->
    self = @
    @sel.change( (self) ->
      select = $(self.target).data("select")
      opponentSelect = $('.player-select').not(self.target).data("select")
      opponentId = opponentSelect.sel.val()

      opponentSelect.buildWithRivals(select.currentId(), opponentId).promise().then( ->
        if opponentId == "0"
          select.cal.setupDatesForPlayer(select.currentId())
        else 
          select.cal.setupDatesForRivalry(select.currentId(), opponentSelect.currentId())
      )
    )
    
  currentId : ->
    return @sel.val()
    
  updateCal : ->
    @cal.setupForPlayer(@currentId())