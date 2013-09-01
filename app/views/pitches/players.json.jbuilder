json.player_ids @players do |json, playerId|
	json.(playerId, :id, :last, :first)
end