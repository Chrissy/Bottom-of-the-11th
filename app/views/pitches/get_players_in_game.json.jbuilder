all_pitchers = @pitchers[0] + @pitchers[1]
all_batters = @batters[0] + @batters[1]
json.pitchers all_pitchers do |json, pitcher|
  json.(pitcher, :pid, :pitcher_name)
end
json.batters all_batters do |json, batter|
  json.(batter, :pid, :batter_name)
end
