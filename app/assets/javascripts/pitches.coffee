pitchTypeHash = 
  FS : "blue"
  SL : "purple"
  FF : "red"
  SI : "orange"
  CH : "green"
  FA : "red"
  CU : "yellow"
  FC : "gray"
  KN : "pink"
  KC : "pink"

draw = (paper,surface,data) ->
  paper.clear()
  for pitch in data.pitches
    c = paper.circle(pitch.x*3, pitch.y*3 - 200, Math.pow(pitch.start_speed/60, 4))
    c.attr("fill", pitchTypeHash[pitch.pitch_type])
    c.attr("opacity", "0.6")
    c.data("pitchName", pitch.pitchName)
    c.data("x", pitch.x)
    c.data("y", pitch.y)
    c.data("pitcherId", pitch.pitcherId)
    c.data("batterId", pitch.batterId)
    c.data("gid", data.gid)
    c.data("pitchId", pitch.pitch_id)
    if pitch.des == "In play, out(s)"
      c.attr("stroke", "#fff")
      c.attr("stroke-width", 2)
    c.hover( 
      -> 
        tooltip = $("<div class='details'></div>")
        tooltip.appendTo(surface)
        .css(
          "left" : "#{this.data('x')*3}px"
          "top" : "#{this.data('y')*3 - 175}px"
        )
        $.ajax(
          url : "/pitches/preview.html?gid=#{this.data("gid")}&pid=#{this.data("pitcherId")}&ptid=#{this.data("pitchId")}"
        )
        .done((data2) ->
          tooltip.html(data2)
        )
        this.data("tooltip", tooltip) 
      -> $(this.data("tooltip")).remove()
    )
  

$ ->
  $surface = $("#surface")
  paper = Raphael("surface", 600, 500);
  
  $.ajax(
    url : "/pitches/get.json"
    context : document.body
  )
  
  .done((data) ->
    draw(paper, $surface, data)
  )
  
  $("#find-by-date").submit( ->  
    $.ajax(
      url : "/pitches/find_by_date?#{$(this).serialize()}"
    )
    .done((data) ->
      $select = $("#find-game select").empty() 
      for game in data.games
        $select.append("<option data-gid='#{game.gid}'>#{game.visit_team_name} at #{game.home_team_name}</option")
    )
    return false
  )
  
  $("#find-game").submit( ->
    gid = $(this).children("select").find(":selected").attr("data-gid")
    $.ajax(
      url: "/pitches/get.json?gid=#{gid}"
    ).done((data) ->
      draw(paper, $surface, data)
      $.ajax(
        url: "/pitches/get_players_in_game.json?gid=#{gid}"
      )
      .done((data) ->
        $pitchersSelect = $("#find-pitcher #pitchers").empty() 
        $battersSelect = $("#find-batter #batters").empty() 
        for pitcher in data.pitchers
          $pitchersSelect.append("<option data-gid='#{pitcher.pid}'>#{pitcher.pitcher_name}</option")
        for batter in data.batters
          $battersSelect.append("<option data-gid='#{batter.pid}'>#{batter.batter_name}</option")
      )
    )
    return false
  )
  
  $("#find-pitcher").submit( ->
    pid = $(this).children("select").find(":selected").attr("data-gid")
    paper.forEach((el) ->
      el.hide()
      el.show() if el.data("pitcherId") == pid
    )
    return false
  )
  
  $("#find-batter").submit( ->
    bid = $(this).children("select").find(":selected").attr("data-gid")
    paper.forEach((el) ->
      el.hide()
      el.show() if el.data("batterId") == bid
    )
    return false
  )