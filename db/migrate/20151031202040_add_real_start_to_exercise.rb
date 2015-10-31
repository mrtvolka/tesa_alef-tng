class AddRealStartToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :real_start, :timestamp
  end
end
