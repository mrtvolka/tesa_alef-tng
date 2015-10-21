class AddPointsToLearningObject < ActiveRecord::Migration
  def change
    add_column :learning_objects, :points, :float
  end
end
