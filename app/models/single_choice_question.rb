class SingleChoiceQuestion < LearningObject

  # Returns correct options
  def get_solution(user_id)
    self.answers.where(is_correct: true).ids
  end

  # Constructs hash for right answer, which has same format as hash posted in student response.
  def construct_righ_hash
    return Answer.where("learning_object_id = (?) AND is_correct= true",self.id).first.id
  end

  def right_answer?(answer, solution)
    answer.to_i == solution[0]
  end
end