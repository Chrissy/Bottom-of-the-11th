class PlayerId < ActiveRecord::Base
  attr_accessible :first, :id, :last, :team_abbrev, :days_played
  
  def performances
    performances = []
    date_codes_array = eval(self.days_played)
    date_codes_array.each do |code|
      performances << Performance.new(self, code) if code
    end
    return performances 
  end
  
  def performance(date_code)
    return Performance.new(self, date_code)
  end

end

class Performance
  attr_reader :date_array
  
  def initialize(player_id, date_code)    
    @date_array = key_to_date_array(date_code)
    @player_id = player_id
  end
  
  def key_to_date_array(key)
    date = []
    date.push(key[0..3].to_i)
    date.push(key[4..5].to_i)
    date.push(key[6..7].to_i)
    return date
  end
    
  # always returns first game (even if there is a double header)
  def game
    team = Team.new(@player_id.team_abbrev)
    game = team.games_for_date(@date_array[0], @date_array[1], @date_array[2])
    return game[0]
  end
  
  def at_bats
    side = (game.home_team_abbrev == @player_id.team_abbrev) ? 'home' : 'away'
    player_at_bats = game.get_atbats.select{ |atbat| atbat.batter_id.to_i == @player_id.id }
    return player_at_bats
  end

  def pitches
    all_pitches = []
    self.at_bats.each do |at_bat|
      all_pitches.concat(at_bat.pitches)
    end
    return all_pitches
  end
  
end
