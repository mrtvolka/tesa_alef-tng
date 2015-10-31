class AddRealEndToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :real_end, :timestamp
  end
end
