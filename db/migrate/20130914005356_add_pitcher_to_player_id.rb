class AddPitcherToPlayerId < ActiveRecord::Migration
  def change
  	  add_column :player_ids, :pitches, :boolean
  end
end
