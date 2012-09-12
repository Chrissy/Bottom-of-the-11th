json.id @firstgame.gid

pitches_with_pitchers = []
pitching = @firstgame.get_pitching

pitching.each do |side|
  side.each do |pitcher|
    pitcher.get_pitches().each do |pitch|
      pitches_with_pitchers << [pitch,pitcher]
    end
  end
end

json.pitches pitches_with_pitchers do |json, pitch|
  json.(pitch[0], :x, :y, :start_speed, :des, :pitch_type, :pitch_id)
  json.pitchName Pitch.get_pitch_name(pitch[0].pitch_type)
  json.pitcherId pitch[1].pid
end
