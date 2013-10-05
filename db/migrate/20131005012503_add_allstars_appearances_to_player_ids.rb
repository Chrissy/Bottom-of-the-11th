class AddAllstarsAppearancesToPlayerIds < ActiveRecord::Migration
  def change
  	add_column :player_ids, :allstar_appearances, :text
  end
end
