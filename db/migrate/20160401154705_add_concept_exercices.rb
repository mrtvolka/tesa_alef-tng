class AddConceptExercices < ActiveRecord::Migration
  create_table :concepts_exercises do |t|
    t.integer :exercise_id, null: false
    t.integer :concept_id, null: false
  end
end
