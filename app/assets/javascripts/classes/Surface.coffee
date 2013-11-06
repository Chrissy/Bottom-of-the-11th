class window.Surface
  circles : []
  lines : [] 

  constructor : ->
    @circleGraphContainer = $("#surface")
    @circleGraph = Raphael("surface", 600, 500)
    @lineGraphContainer = $("#surface2")
    @lineGraph = Raphael("surface2", 800, 600)

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
      return if pitch.pitch_type == "IN"
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
    hits = []
    strikes = []
    pitches = []
    for pitch in data.pitches
      return if pitch.pitch_type == "IN"
      x1 = 0
      y1 = 400 - parseFloat(pitch.z0)*50
      x2 = 800
      y2 = parseFloat(pitch.pz)*50
      cx = (parseFloat(pitch.break_y)/12)*50
      cy = (parseFloat(pitch.pfx_z)/12)*50
      p = @lineGraph.path("M #{x1} #{y1} q #{cx} #{cy} #{x2} #{y2}")
      p.attr("stroke", @pitchTypeHash[pitch.pitch_type])
      p.attr("stroke-width", 0.75)
      @pushData(p,pitch)
      if pitch.des == "In play, run(s)" || pitch.des == "In play, no out"
        hits.push(p) 
      else if pitch.ab_num == "last" && (pitch.des == "Swinging Strike" || pitch.des == "Called Strike")
        strikes.push(p)
      
      pitches.push(p)
      self = @

      p.hover(
        ->
          this.attr("stroke-width", 2)
          this.attr("stroke", "#fff")
          p.data("tooltip", self.addTooltip(self.lineGraphContainer,this))
          twin = self.findTwin(self.circleGraph, this)
          twin.attr("stroke-width",3)
          twin.attr("stroke", "#fff")
          twin.toFront()
          this.toFront()
        -> 
          self.removeTooltip(this)
          if this.data("hit") || this.data("strike")
            this.attr("stroke",  then self.hitTypeHash[this.data("pitchAbbr")])
            this.attr("stroke-width", if this.data("hit") then 2 else 1)
          else
            this.attr("stroke-width", 1)
            this.attr("stroke",  then self.pitchTypeHash[this.data("pitchAbbr")])
          twin = self.findTwin(self.circleGraph, this)
          twin.attr("stroke", self.pitchTypeHash[twin.data("pitchAbbr")])
          twin.attr("stroke-width", 1)
      )

    for hit in hits
      self = @
      color = @hitTypeHash[hit.data("pitchAbbr")]
      hit.toFront()
      hit.attr("stroke", color)
      hit.attr("opacity", 1)
      hit.attr("stroke-width", 2)

      pt = hit.getPointAtLength(hit.getTotalLength());   
      c = @lineGraph.circle(pt.x, pt.y, 0)
      c.attr("fill", color)
      c.attr("stroke", "transparent").toFront()
      c2 = @lineGraph.circle(pt.x, pt.y, 0)
      c2.attr("fill", "transparent")
      c2.attr("stroke", color)
      hit.data("hit", true)

      window.setTimeout( -> 
        self.animateCircle(c, c2)
      , self.radius(hit.data("pitchSpeed"))/3 * 1000 + 200)

    for strike in strikes
      color = @hitTypeHash[strike.data("pitchAbbr")]
      strike.toFront()
      strike.attr("stroke", color)
      strike.attr("stroke-width", 1)
      strike.data("strike", true)

    for pitch in pitches
      self.animatePath(pitch)

  pitchTypeHash :
    FF : "rgb(126, 23, 34)" #fastball/red
    FA : "rgb(149, 64, 17)" #fastball/red
    FT : "rgb(149, 64, 17)" #fastball/red
    FC : "rgb(161, 134, 27)" #cutter/yellow
    SI : "rgb(162, 73, 83)" #sinker/pink
    SL : "rgb(115, 12, 69)" #slider/magenta
    FS : "rgb(77, 46, 90)" #splitter/purple
    CU : "rgb(25, 57, 106)" #curve/blue
    CH : "rgb(10, 97, 115)" #change/turqoise
    KN : "rgb(13, 86, 74)" #knuckle/green
    KC : "rgb(13, 86, 74)" #knuckle-curve/green

  hitTypeHash :
    FF : "rgb(201, 54, 49)" #fastball/red
    FA : "rgb(201, 54, 49)" #fastball/red
    FT : "rgb(201, 54, 49)" #fastball/red
    FC : "rgb(232, 207, 84)" #cutter/yellow
    SI : "rgb(229, 122, 130)" #sinker/pink
    SL : "rgb(202, 53, 121)" #slider/magenta
    FS : "rgb(155, 78, 187)" #splitter/purple
    CU : "rgb(40, 108, 177)" #curve/blue
    CH : "rgb(105, 173, 187)" #change/turqoise
    KN : "rgb(76, 164, 135)" #knuckle/green
    KC : "rgb(76, 164, 135)" #knuckle-curve/green
  
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

  animatePath : (pitch) ->
    strike = !!pitch.data("strike")
    path = pitch.node
    dashString = ""
    length = path.getTotalLength()
    path.style.strokeDasharray =  if strike then "1 #{length} #{@.dashArray(length)}" else "#{length} #{length}"
    path.style.strokeDashoffset = if strike then '0' else length
    path.getBoundingClientRect()
    path.style.transition = path.style.WebkitTransition = "stroke-dashoffset #{@.radius(pitch.data("pitchSpeed"))/2}s ease-out"
    path.style.strokeDashoffset = if strike then (length * -1) else 0

  animateCircle : (c, c2) ->
    c.animate({"r" : 3}, 200)
    c2.animate({"r" : 6}, 200)

  dashArray : (length) ->
    str = ""
    for i in [0..(length/2)]
      str += "2 "
    return str

