class AddIsSpecialQuestionToLearningObject < ActiveRecord::Migration
  def change
    add_column :learning_objects, :is_special_question, :boolean
  end
end
