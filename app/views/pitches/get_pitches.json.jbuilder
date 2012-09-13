json.gid @game.gid

json.pitches @pitches_with_pitchers do |json, pitch|
  json.(pitch[0], :x, :y, :start_speed, :des, :pitch_type, :pitch_id)
  json.pitchName Pitch.get_pitch_name(pitch[0].pitch_type)
  json.pitcherId pitch[1]
  json.batterId pitch[2]
end