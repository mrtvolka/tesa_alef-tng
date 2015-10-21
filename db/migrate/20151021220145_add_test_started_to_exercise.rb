class AddTestStartedToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :test_started, :boolean
  end
end
