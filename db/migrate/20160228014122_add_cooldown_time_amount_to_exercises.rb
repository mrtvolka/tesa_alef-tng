class AddCooldownTimeAmountToExercises < ActiveRecord::Migration
  def change
    add_column  :exercises, :cooldown_time_amount, :integer
  end
end
