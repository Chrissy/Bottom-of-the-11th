require 'Game'

class PitchesController < ApplicationController  
  
  def index
    @game = Game.find_by_date(2012,5,13)[0]
    respond_to do |format|
      format.html {}
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
  
  def find_by_date
    y = params["date_of"]["date-of(1i)"]
    m = params["date_of"]["date-of(2i)"]
    d = params["date_of"]["date-of(3i)"]
    @games = Game.find_by_date(y,m,d)
    respond_to do |format|
      format.json {}
    end 
  end
  
  def get_pitches
    if params[:gid] 
      @game = Game.new(params[:gid])
    else 
      games = Game.find_by_date(2012,5,13)
      @game = games[0]
    end
    @pitches_with_pitchers = []
    atBats = @game.get_atbats()
    
    atBats.each do |atbat|
        atbat.pitches.each do |pitch|
          @pitches_with_pitchers << [pitch,atbat.pitcher_id,atbat.batter_id]
      end
    end
    
    respond_to do |format|
      format.json {}
    end
  end
  
  def get_players_in_game
    game = Game.new(params[:gid])
    @batters = []
    @pitchers = game.get_pitching()
    @batters[0] = game.get_batters("home")
    @batters[1] = game.get_batters("away")
    respond_to do |format|
      format.json {}
    end
  end
  
end