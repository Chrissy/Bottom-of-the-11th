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
    if params[:pid] && params[:dates] 
      @pitches_with_pitchers = []
      player = PlayerId.find(params[:pid])
      params[:dates].each do |date|
        begin 
          @pitches_with_pitchers.concat(player.performance(date).pitches)
        rescue 
          puts "there was an error"
        end
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

  def dates
    @dates = PlayerId.find(params[:pid]).performances.map(&:date_array)
    respond_to do |format|
      format.json {}
    end
  end

  def dates_faced
    @dates = PlayerId.find(params[:batter])
                     .pitching_rivalry(params[:pitcher])
                     .dates_faced
                     
    respond_to do |format|
      format.json { render :template => 'pitches/dates.json.jbuilder' }
    end
  end 

  def pitchers_faced
    player_ids = PlayerId.find(params[:pid]).pitchers_faced
    @players = player_ids.collect { |player_id| PlayerId.find_by_id(player_id) }
    @players.compact!.sort! { |a, b| a.last <=> b.last }

    respond_to do |format|
      format.json { render :template => 'pitches/players.json.jbuilder' }
    end
  end

  def all_players
    @players = PlayerId.all
    respond_to do |format|
      format.json { render :template => 'pitches/players.json.jbuilder' }
    end
  end
  
end