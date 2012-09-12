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

$ ->
  paper = Raphael("surface", 600, 500);
  
  $.ajax(
    url : "/pitches.json"
    context : document.body
  )
  
  .done((data) ->
    surface = $("#surface")    
    for pitch in data.pitches
      c = paper.circle(pitch.x*3, pitch.y*3 - 200, Math.pow(pitch.start_speed/60, 4))
      c.attr("fill", pitchTypeHash[pitch.pitch_type])
      c.attr("opacity", "0.6")
      c.data("pitchName", pitch.pitchName)
      c.data("x", pitch.x)
      c.data("y", pitch.y)
      c.data("pitcherId", pitch.pitcherId)
      c.data("gid", data.id)
      c.data("pitchID", pitch.pitch_id)
      if pitch.des == "In play, out(s)"
        c.attr("stroke", "#fff")
        c.attr("stroke-width", 2)
      c.hover( 
        -> 
          console.log(this.data("pitchID"))
          tooltip = $("<div class='details'></div>")
          tooltip.appendTo(surface)
          .css(
            "left" : "#{this.data('x')*3}px"
            "top" : "#{this.data('y')*3 - 175}px"
          )
          $.ajax(
            url : "/pitches/preview.html?gid=#{this.data("gid")}&pid=#{this.data("pitcherId")}&ptid=#{this.data("pitchID")}"
          )
          .done((data2) ->
            tooltip.html(data2)
          )
          this.data("tooltip", tooltip) 
        -> $(this.data("tooltip")).remove()
      ) 
  )