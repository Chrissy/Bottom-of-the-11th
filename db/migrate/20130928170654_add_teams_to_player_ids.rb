class AddTeamsToPlayerIds < ActiveRecord::Migration
  def change
  	add_column :player_ids, :teams, :text
  end
end
