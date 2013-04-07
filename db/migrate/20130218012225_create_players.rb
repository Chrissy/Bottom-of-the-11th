class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :id
      t.string :first
      t.string :last
      t.string :team_abbrev

      t.timestamps
    end
  end
end
