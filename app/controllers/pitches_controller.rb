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
    @pitches_with_pitchers = []
    player = PlayerId.find(params[:pid])

    if params[:count]
      @pitches_with_pitchers = player.last_n_pitches(params[:count].to_i)
    else 
      params[:dates].each do |date|
        if params[:bid]
          pitches = RivalryPerformance.new(params[:bid], params[:pid], date).pitches
          @pitches_with_pitchers.concat(pitches)
        else
          @pitches_with_pitchers.concat(player.performance(date).pitches)
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
    player1 = PlayerId.find(params[:player1])
    player2 = PlayerId.find(params[:player2])

    @dates = Rivalry.new(player1, player2).rivalry_performances.map(&:date_array)

    respond_to do |format|
      format.json { render :template => 'pitches/dates.json.jbuilder' }
    end
  end 

  def players_faced
    player = PlayerId.find(params[:pid])
    player_ids = player.players_faced
    players = player_ids.collect { |player_id| PlayerId.find_by_id(player_id) }
    players.compact!.sort! { |a, b| a.last <=> b.last }
    @players = players.delete_if {|x| x.teams.last == player.teams.last }

    @allstars = PlayerId.find_allstars(@players, 30)
    @allstars.sort! { |a, b| (a.divisions.last == b.divisions.last) ? 1 : -1 }

    division_allstars = []
    league_allstars = []
    @allstars.each do |allstar|
      if allstar.divisions.last == player.divisions.last
        division_allstars << allstar 
      elsif allstar.divisions.last.try(:[], 1) == player.divisions.last.try(:[], 1) && player.divisions.last.try(:[], 1)
        league_allstars << allstar
      end
    end

    @allstars = division_allstars.take(5) + league_allstars.take(5)

    respond_to do |format|
      format.json { render :template => 'pitches/players.json.jbuilder' }
    end
  end

  def all_players
    @players = PlayerId.find(:all, :conditions => ["pitches=?",true])
    @allstars = PlayerId.allstar_pitchers(10)
    respond_to do |format|
      format.json { render :template => 'pitches/players.json.jbuilder' }
    end
  end
  
end