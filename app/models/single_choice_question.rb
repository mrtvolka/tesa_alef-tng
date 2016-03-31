class SingleChoiceQuestion < LearningObject

  def get_solution(user_id)
    self.answers.where(is_correct: true).ids
  end

  def construct_righ_hash
    #"12"
    return Answer.where("learning_object_id = (?) AND is_correct= true",self.id).first.id
  end

  def right_answer?(answer, solution)
    answer.to_i == solution[0]
  end
end