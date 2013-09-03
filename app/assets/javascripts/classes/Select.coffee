class window.Select

  constructor : (parent, calendar) ->
    @select_element = $('<select data-placeholder="-----"/>')
    $(parent).append(@select_element)
    @sel = @select_element.chosen()
    @cal = calendar

  buildWithRivals : (id, default_rival) ->
    self = @
    $.get("/pitches/pitchers_faced.json?pid=#{id}").then(
      (data) ->
        self.build(data.player_ids)
        self.changePlayer(default_rival)
      -> 
        console.log "could not find players"
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
    @sel.prepend("<option></option>").trigger('liszt:updated')
  
  changePlayer : (id) ->
    option = @select_element.children('option').filter("[value='#{id}']")[0]
    @sel[0].selectedIndex = option.index
    @sel.trigger('liszt:updated')
    
  onChange : (func) ->
    self = @
    @sel.change( -> func(self))
    
  currentId : ->
    return @sel.val()
    
  updateCal : ->
    @cal.setupForPlayer(@currentId())