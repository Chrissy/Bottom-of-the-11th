json.games @games do |json, game|
  json.(game, :gid, :home_team_name, :visit_team_name)
end