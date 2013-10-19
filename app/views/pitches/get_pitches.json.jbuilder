json.pitches @pitches_with_pitchers do |json, pitch|
  json.(pitch, :x, :y, :z0, :pz, :break_y, :pfx_z, :start_speed, :des, :pitch_type, :pitch_id, :ab_num)
  json.pitchName Pitch.get_pitch_name(pitch.pitch_type)
end