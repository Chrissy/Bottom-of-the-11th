class window.Select

  constructor : (parent, calendar) ->
    @select_element = $('<select class="player-select" data-placeholder="-----"/>')
    $(parent).append(@select_element)
    @sel = @select_element.chosen()
    @cal = calendar
    @select_element.data("select", @)
    @.initChangeEvent()

  buildWithRivals : (default_rival) ->
    self = @
    id = $('.player-select').not(self.select_element).data("select").sel.val()
    $.get("/pitches/players_faced.json?pid=#{id}").then(
      (data) ->
        self.build(data.player_ids, data.allstars)
        self.changePlayer(default_rival)
    )

  updateCalWithCrossReferents : ->
    @cal.setupDatesForRivalry(@currentId())

  buildWithAll : (selectedPlayer) ->
    self = @
    $.get("/pitches/all_players.json").then(
      (data) ->
        selectedPlayer = data.allstars[0].id if selectedPlayer == "first"
        self.build(data.player_ids, data.allstars)
        self.changePlayer(selectedPlayer)
      -> 
        console.log "could not find players"
    )

  build : (players, allstars) ->
    optionsString = ''
    allstarString = '' 
    playerString = ''
    for player in players
      playerString += "<option value=#{player.id}>#{player.last} #{player.first}</option>"
    for allstar in allstars
      allstarString += "<option value=#{allstar.id}>#{allstar.last} #{allstar.first}</option>"
    optionsString = "<optgroup label='allstars'>#{allstarString}</optgroup><optgroup label='players'>#{playerString}</optgroup>"
    @select_element.html(optionsString)  
    @sel.prepend("<option value='0'>--------</option>").trigger('liszt:updated')
  
  changePlayer : (id) ->
    option = @select_element.find('option').filter("[value='#{id}']")[0]
    @sel[0].selectedIndex = option.index
    @sel.trigger('liszt:updated')
    
  initChangeEvent : ->
    self = @
    @sel.change( (self) ->
      select = $(self.target).data("select")
      opponentSelect = $('.player-select').not(self.target).data("select")
      opponentId = opponentSelect.sel.val()
      opponentSelect.buildWithRivals(opponentId).promise().then( ->
        if opponentId == "0"
          select.cal.setupForSelect(select.sel)
        else
          select.cal.setupDatesForRivalry(select.currentId(), opponentSelect.currentId())
      )
    )
    
  currentId : ->
    return @sel.val()
    
  updateCal : ->
    @cal.setupForSelect(@sel)