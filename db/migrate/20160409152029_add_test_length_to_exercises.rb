class AddTestLengthToExercises < ActiveRecord::Migration
  def change
    add_column :exercises, :test_length, :integer
  end
end
