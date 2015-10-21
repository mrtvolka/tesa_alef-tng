class AddIsTestQuestionToLearningObject < ActiveRecord::Migration
  def change
    add_column :learning_objects, :is_test_question, :boolean
  end
end
