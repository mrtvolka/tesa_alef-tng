class RemoveTestStartedFromExercise < ActiveRecord::Migration
  def change
    remove_column :exercises, :test_started, :boolean
  end
end
