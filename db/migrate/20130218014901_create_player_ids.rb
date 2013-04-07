class CreatePlayerIds < ActiveRecord::Migration
  def change
    create_table :player_ids do |t|
      t.integer :id
      t.string :first
      t.string :last
      t.string :team_abbrev

      t.timestamps
    end
  end
end
