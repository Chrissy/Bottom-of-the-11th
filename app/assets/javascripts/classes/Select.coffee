class window.Select

  constructor : (selector, calendar) ->
    @select_element = $(selector).first()
    @sel = @select_element.chosen()
    @cal = calendar
    @select_element.data("select", @)

  setup : ->
    if @opponentId() == "0" || @currentId() == "0"
      @cal.setupForSelect(@sel)
    else
      @cal.setupDatesForRivalry(@opponentId(), @currentId())

  buildWithRivals : ->
    self = @
    stored_id = if @currentId() then @currentId() else 0
    $.get("/pitches/players_faced.json?pid=#{self.opponentId()}").then(
      (data) ->
        self.build(data.player_ids, data.allstars)
        self.changePlayer(stored_id)
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
    option = @select_element.find("option[value='#{id}']")[0]
    @sel[0].selectedIndex = option.index
    @sel.trigger('liszt:updated')
    
  onChange : (func) ->
    self = @
    @sel.change( (target) ->
      func(self)
    )
    
  currentId : ->
    return @sel.val()
    
  updateCal : ->
    @cal.setupForSelect(@sel)

  opponentSelect : ->
    return $('.player-select').not(@.select_element).data("select")

  opponentId : ->
    return @opponentSelect().sel.val()