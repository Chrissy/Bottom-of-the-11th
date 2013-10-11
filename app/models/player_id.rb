class PlayerId < ActiveRecord::Base
  attr_accessible :first, :id, :last, :team_abbrev, :days_played
  serialize :teams, Array
  serialize :days_played, Array
  serialize :allstar_appearances, Array
  
  def performances
    performances = []
    self.days_played.each do |code|
      performances << Performance.new(self, code) if code
    end
    return performances 
  end

  def date_codes_array
    self.days_played
  end
  
  def performance(date_code)
    return Performance.new(self, date_code)
  end

  def pitcher?
    pitcher = Team.new(team_abbrev).get_starters_unique(2012).map(&:pid).include?(id.to_s) || Team.new(team_abbrev).get_closers_unique(2012).map(&:pid).include?(id.to_s)
  end

  def team(year)
    self.teams.find { |team| team[1] == year }.first
  end

  def pitches?
    self.pitches
  end

  def players_faced
    player_ids = []
    pitcher = pitcher?

    performances.each do |performance|
      begin
        if pitcher
          player_ids.concat(performance.batters_faced.uniq)
        else
          player_ids.concat(performance.pitchers_faced.uniq)
        end
      rescue
        puts "...failed to load pitchers for #{performance.formatted_date}"
      end
    end
    player_ids.uniq
  end

  def pitching_rivalry(pid)
    Rivalry.new(PlayerId.find(pid), self)
  end

  def self.find_allstars(players, limit)
    players.sort { |p1, p2| p2.allstar_appearances.count <=> p1.allstar_appearances.count }[0..50].shuffle[0..limit]
  end

  def self.allstars(limit)
    find_allstars(PlayerId.all, limit)
  end

  def self.allstar_batters(limit)
    find_allstars(PlayerId.find(:all, :conditions => ["pitches=?",false]), limit)
  end

  def self.allstar_pitchers(limit)
    find_allstars(PlayerId.find(:all, :conditions => ["pitches=?",true]), limit)
  end

end

class Performance
  attr_reader :date_array
  
  def initialize(player_id, date_code)    
    @date_array = Performance.key_to_date_array(date_code)
    @player_id = player_id
    @player_team = @player_id.team(@date_array[0])
  end
  
  def self.key_to_date_array(key)
    date = []
    date.push(key[0..3].to_i)
    date.push(key[4..5].to_i)
    date.push(key[6..7].to_i)
    return date
  end

  def formatted_date
    return "#{@date_array[2]}/#{@date_array[1]}/#{@date_array[0]}"
  end

  # always returns first game (even if there is a double header)
  def game
    team = Team.new(@player_team)
    game = team.games_for_date(@date_array[0], @date_array[1], @date_array[2])
    return game[0]
  end
  
  def at_bats
    if @player_id.pitcher?
      player_at_bats = game.get_atbats.select{ |atbat| atbat.pitcher_id.to_i == @player_id.id }
    else
      player_at_bats = game.get_atbats.select{ |atbat| atbat.batter_id.to_i == @player_id.id }
    end
    return player_at_bats
  end

  def pitches
    all_pitches = []
    self.at_bats.each do |at_bat|
      all_pitches.concat(at_bat.pitches)
    end
    return all_pitches
  end

  def side
    (game.home_team_abbrev == @player_team) ? 'home' : 'away'
  end

  def home?
    return true if game.home_team_abbrev == @player_team 
  end

  def opponent_abbrev
    home? ? game.visit_team_abbrev : game.home_team_abbrev
  end

  def pitchers_faced
    game.get_pitchers(home? ? 'away' : 'home').map(&:pid) 
  end 

  def batters_faced
    game.get_batters(home? ? 'away' : 'home').map(&:pid) 
  end 
  
end

class Rivalry
  attr_reader :rivalry_performances, :pitcher, :batter

  def initialize(player1, player2)
    @pitcher = player1.pitches ? player1 : player2
    @batter = player1.pitches ? player2 : player1

    pitcher_dates = @pitcher.date_codes_array
    batter_dates = @batter.date_codes_array
    pitcher_dates.shift
    batter_dates.shift
    @rivalry_performances = []
    pitcher_dates.each do |datecode|
      if datecode && (Performance.new(@pitcher, datecode).opponent_abbrev == @batter.team(Performance.key_to_date_array(datecode)[0]))
        @rivalry_performances << RivalryPerformance.new(@pitcher.id, @batter.id, datecode)
      end
    end
  end

  def player1
    PlayerId.find(@player1_id)
  end

  def player2
    PlayerId.find(@player2_id)
  end

end

class RivalryPerformance < Performance
  def initialize(pitcher_int, batter_int, datecode)
    @pitcher_int = pitcher_int
    @batter_int = batter_int
    pitcher_id = PlayerId.find(pitcher_int)
    super(pitcher_id, datecode.to_s)
  end

  def at_bats
    game.get_atbats.select{ |atbat| atbat.pitcher_id.to_i == @pitcher_int.to_i && atbat.batter_id.to_i == @batter_int.to_i }
  end
end
