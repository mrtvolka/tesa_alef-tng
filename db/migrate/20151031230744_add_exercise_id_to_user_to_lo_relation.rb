class AddExerciseIdToUserToLoRelation < ActiveRecord::Migration
  def change
    add_column :user_to_lo_relations, :exercise_id, :integer
  end
end
