require 'Game'

class PitchesController < ApplicationController  
  
  def index
    games = Game.find_by_date(2012,5,13)
    @firstgame = games[8]

    respond_to do |format|
      format.html {}
      format.json {}
    end  
  end
  
  def preview
    @gid = params[:gid]
    @pid = params[:pid]
    @ptid = params[:ptid]
    @pitch = Game.new(@gid).get_pitches(@pid).find{|x|x.pitch_id==@ptid}
     
    respond_to do |format|
      format.html { render :layout => false }
    end
  end
  
end