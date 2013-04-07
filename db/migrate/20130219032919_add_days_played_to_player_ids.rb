class AddDaysPlayedToPlayerIds < ActiveRecord::Migration
  def change
    add_column :player_ids, :days_played, :string
  end
end
