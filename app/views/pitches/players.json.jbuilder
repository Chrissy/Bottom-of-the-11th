json.player_ids @players do |json, playerId|
	json.(playerId, :id, :last, :first)
end

json.allstars @allstars do |json, allstar|
	json.(allstar, :id, :last, :first)
end