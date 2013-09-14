class DatabaseTools
  
  def save_schedule_for_all_players(year)
    PlayerId.all.each do |player_id|
      schedule = get_player_games_for_year(player_id, year)
      player_id.days_played = schedule.to_s
      player_id.save
    end
  end
  
  def get_player_games_for_year(player_id, year)
    games_participation = [], string_exceptions = 0
    team = Team.new(player_id.team_abbrev)
    all_games = team.all_games(year)
    all_games.each do |game|
      participation = did_player_participate_in_game?(player_id, game)
      games_participation << participation
    end
    return games_participation[2..games_participation.length].uniq #uhh fix this one day
  end
  
  def did_player_participate_in_game?(player, game)
    atbats = game.get_atbats
    participation_date = false
    atbats.each do |atbat|
      if atbat.pitcher_id == player.id.to_s || atbat.batter_id == player.id.to_s
        participation_date = "#{game.year}#{game.month}#{game.day}"
      end
    end
    return participation_date
  end

  def self.save_pitcher_for_all_players
    PlayerId.all.each do |player|
      if player.pitches == nil
        player.pitches = player.pitcher?
        player.save
      end
    end
  end
  
  def self.save_player_ids_for_year(year)
    puts "saving unique players..."
    players = get_players_for_year(year)
    players.each do |player|
      player_id = PlayerId.new do |p|
        puts "saving #{p[1]} #{p[2]}"
        p.id = player[0]
        p.first = player[1]
        p.last = player[2]
        p.team_abbrev = player[3]
      end
      PlayerId.find_by_id(player[0]).try(:delete)
      player_id.save
    end
  end
      
  def self.get_players_for_year(year)
    players = []
    Team.teams.sort.each do |team|
      team = Team.new(team[0])
      players.concat(get_players_for_team(team, year))
    end
    players.uniq
  end
  
  def self.get_players_for_team(team, year)
    players = []
    game_sample = [1,7,14,21,28] #only sample a few dates a month
    (4..5).each do |month|
      game_sample.each do |day|
        begin
          game = Game.new(team.games_for_date(year, month, day)[0])
        rescue
          puts "could not create game object"
        else
          players.concat(get_players_for_game(game, team))
        end
      end
    end
    players.uniq
  end
  
  def self.get_players_for_game(game, team)
    players = []
    begin
      rosters = game.get_rosters
    rescue
      puts "issue creating a roster"
      rosters = nil
    end
    side = (game.visit_team_abbrev == team.abrev) ? 0 : 1
    if rosters
      rosters[side].players.each do |player|
        players << [player.pid, player.first, player.last, player.team_abbrev]
      end
    end
    players
  end
    
end