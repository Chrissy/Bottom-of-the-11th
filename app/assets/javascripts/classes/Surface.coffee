class window.Surface
  circles : []
  lines : [] 

  constructor : ->
    @circleGraphContainer = $("#surface")
    @circleGraph = Raphael("surface", 600, 500)
    @lineGraphContainer = $("#surface2")
    @lineGraph = Raphael("surface2", 800, 300)

    width = $("#container").innerWidth()
    height = $("#container").innerHeight()
    @lineGraph.setViewBox(0, 0, 800, 300, true)
    @lineGraph.setSize(width, height)

    width = $("#surface").innerWidth()
    height = $("#surface").innerHeight()
    @circleGraph.setViewBox(0, 0, 600, 500, true)
    @circleGraph.setSize(width, height)

  draw : (@data) ->
    @circleGraph.clear()
    @lineGraph.clear()
    @drawCircles(data)
    @drawLines(data)
    
  drawCircles : (data) ->
    for pitch in data.pitches
      c = @circleGraph.circle(pitch.x*3, pitch.y*3 - 200, @radius(pitch.start_speed))
      c.attr("fill", @pitchTypeHash[pitch.pitch_type])
      c.attr("opacity", "0.6")
      if pitch.des == "In play, run(s)"
        c.attr("stroke", "#fff")
        c.attr("stroke-width", 2)

      @pushData(c,pitch)
      @circles.push(c)  

      self = @

      c.hover( 
        ->
          c.data("tooltip", self.addTooltip(surface,this))
          this.animate({"r" : self.radius(this.data("pitchSpeed")) + 3},50)
          twin = self.findTwin(self.lineGraph, this)
          twin.attr("stroke-width",3)
          twin.attr("stroke", "#fff")
          twin.toFront()
        -> 
          self.removeTooltip(this)
          this.animate({"r" : self.radius(this.data("pitchSpeed"))},50)
          twin = self.findTwin(self.lineGraph, this).animate("stroke-width",1)
          twin.attr("stroke-width",1)
          twin.attr("stroke", self.pitchTypeHash[twin.data("pitchAbbr")])
      )

  drawLines : (data) ->
    for pitch in data.pitches
      x1 = 0
      y1 = 400 - parseFloat(pitch.z0)*50
      x2 = 800
      y2 = parseFloat(pitch.pz)*50
      cx = (parseFloat(pitch.break_y)/12)*50
      cy = (parseFloat(pitch.pfx_z)/12)*50
      p = @lineGraph.path("M #{x1} #{y1} q #{cx} #{cy} #{x2} #{y2}")
      p.attr("stroke", @pitchTypeHash[pitch.pitch_type])
      @pushData(p,pitch)
      
      self = @
      
      p.hover(
        ->
          this.animate({"stroke-width" : 4},50)
          this.attr("stroke", "#fff")
          p.data("tooltip", self.addTooltip(self.lineGraphContainer,this))
          twin = self.findTwin(self.circleGraph, this)
          twin.attr("stroke-width",3)
          twin.attr("stroke", "#fff")
          twin.toFront()
          this.toFront()
        -> 
          this.animate({"stroke-width" : 1},50)
          self.removeTooltip(this)
          twin = self.findTwin(self.circleGraph, this)
          twin.attr("stroke-width",1)
          this.attr("stroke", self.pitchTypeHash[this.data("pitchAbbr")])
          twin.attr("stroke", self.pitchTypeHash[twin.data("pitchAbbr")])
      )

  pitchTypeHash : 
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
  
  pushData : (el,pitch) ->
    el.data("pitchName", pitch.pitchName)
    el.data("pitchAbbr", pitch.pitch_type)
    el.data("x", pitch.x)
    el.data("y", pitch.y)
    el.data("pitcherId", pitch.pitcherId)
    el.data("batterId", pitch.batterId)
    el.data("gid", pitch.gameId)
    el.data("pitchId", pitch.pitch_id)
    el.data("pitchSpeed", pitch.start_speed)
  
  loadDetails : (pitch) ->
    gid = this.data("gid")
    pitcherId = this.data("pitcherId")
    ptid = this.data("pitchId")
  
    $.ajax( url : "/pitches/preview.html?gid=#{gid}&pid=#{pid}&ptid=#{ptid}" )
    .done((data2) ->
      app.detailsBox.html(data2)
    )
  
  findTwin : (paper,target) ->
    element = ""
    paper.forEach((el) ->
      if el.data("pitchId") == target.data("pitchId")
        element = el
        return
    )
    return element
  
  addTooltip : (surface,$el) ->
    $tooltip = $(
      "<ul class='details' data-id='p#{$el.data("pitchId")}'>
        <li>Pitch Speed: #{$el.data("pitchSpeed")}</li>
        <li>Pitch Type #{$el.data("pitchName")}</li>
      </ul>"
    )
    .css(
      "left" : "#{$el.data('x')*3}px"
      "top" : "#{$el.data('y')*3 - 175}px"
    )
    $tooltip.appendTo(surface)
  
  removeTooltip : ($el) ->
    $(".details[data-id='p#{$el.data('pitchId')}']").remove()

  radius : (speed) ->
    return Math.pow(speed/60, 4)

