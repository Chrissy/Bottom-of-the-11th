class ChangeDaysPlayedToText < ActiveRecord::Migration
  def up
      change_column :player_ids, :days_played, :text
  end
  def down
      # This might cause trouble if you have strings longer
      # than 255 characters.
      change_column :player_ids, :days_played, :string
  end
end
