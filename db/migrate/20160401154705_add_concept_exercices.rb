class AddConceptExercices < ActiveRecord::Migration
  create_join_table :concepts, :exercises
end
